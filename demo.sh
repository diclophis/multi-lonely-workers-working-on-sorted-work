#!/bin/sh

#for I in customer-a customer-b customer-c customer-d
#do
#  bundle exec rake add_events INTEGRATION_ID=$I
#done

TERM_CHILD=1 QUEUE=receive bundle exec rake resque:work &
TERM_CHILD=1 QUEUE=receive bundle exec rake resque:work &
TERM_CHILD=1 QUEUE=receive bundle exec rake resque:work
