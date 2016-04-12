#!/usr/bin/env bash

cd Projects/convertation_service
# load rvm ruby
source ../../.rvm/environments/ruby-2.2.1@convert_service
ruby task_manager.rb
