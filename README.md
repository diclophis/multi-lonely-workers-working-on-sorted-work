# multi worker mutexed per id ordered queue

This resque example only allows 1 job per `INTEGRATION_ID` to be executed at a time.

    TERM_CHILD=1 QUEUE=receive bundle exec rake resque:work
    bundle exec rake add_event INTEGRATION_ID=b EVENT_ID=8

