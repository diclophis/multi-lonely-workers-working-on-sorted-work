require 'rubygems'
require 'resque'
require 'resque-lonely_job'

class Worker
  extend Resque::Plugins::LonelyJob

  @queue = :receive

  def self.set_name_for_all_events(integration_id)
    ["all_events", integration_id].join(":")
  end

  def self.set_name_for_processed_events(integration_id)
    ["processed_events", integration_id].join(":")
  end

  def self.set_name_for_tmp_sorted_events(integration_id)
    ["tmp_events", integration_id].join(":")
  end

  def self.add_events(integration_id, event_ids)
    event_ids.each do |event_id|
      Resque.redis.zadd(set_name_for_all_events(integration_id), Time.now.to_f, event_id)
    end
    Resque.enqueue(self, integration_id)
  end

  def self.redis_key(integration_id)
    "worker:mutex:#{integration_id}"
  end

  def self.perform(integration_id)
    puts [:perform, integration_id].inspect
    # ZUNIONSTORE tmp 2 all processed WEIGHTS 1 0 AGGREGATE MIN
    # zunionstore(destination, keys, options = {}) ⇒ Fixnum
    Resque.redis.zunionstore(set_name_for_tmp_sorted_events(integration_id), [
      set_name_for_all_events(integration_id), 
      set_name_for_processed_events(integration_id)
    ], {:weights => [1, 0], :aggregate => "min"})

    # ZREVRANGEBYSCORE tmp +inf 1 WITHSCORES
    # zrevrangebyscore(key, max, min, options = {}) ⇒ Object
    range = Resque.redis.zrevrangebyscore(set_name_for_tmp_sorted_events(integration_id), "+inf", 1, {:with_scores => true})
    range.reverse.each do |event_id, score|
      # do_work_with(event_id)
      #puts [:starting, integration_id, event_id].inspect
      sleep 5
      puts [:processed, integration_id, event_id].inspect
      Resque.redis.zadd(set_name_for_processed_events(integration_id), score, event_id)
    end
  rescue SignalException => signal
    puts Signal.signame(signal.signo)
    case Signal.signame(signal.signo)
      when "INT", "TERM"
        puts [:interupted, signal].inspect
        Resque.enqueue(self, integration_id)
    end
  end
end
