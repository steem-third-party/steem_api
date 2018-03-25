require "bundler/gem_tasks"
require "rake/testtask"
require 'steem_api'
require 'awesome_print'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

task :console do
  exec "irb -r steem_api -I ./lib"
end

task :build do
  exec 'gem build steem_api.gemspec'
end

task :push do
  exec "gem push steem_api-#{SteemApi::VERSION}.gem"
end

import 'tasks/transfers.rake'
import 'tasks/apps.rake'
import 'tasks/crosscheck.rake'
import 'tasks/rewards.rake'
import 'tasks/proxied.rake'

desc 'Rich list.'
task :richlist, [:symbol, :limit] do |t, args|
  now = Time.now.utc
  symbol = (args[:symbol] || 'MVESTS').upcase
  limit = (args[:limit] || '100').to_i
  
  accounts = SteemApi::Account.limit(limit)
  accounts = case symbol
  when 'VESTS'
    accounts.order("TRY_PARSE(REPLACE(vesting_shares, ' VESTS', '') AS float) DESC")
    accounts.pluck(:name, :vesting_shares).to_h
  when 'MVESTS'
    accounts.order("TRY_PARSE(REPLACE(vesting_shares, ' VESTS', '') AS float) DESC")
    accounts.pluck(:name, "TRY_PARSE(REPLACE(vesting_shares, ' VESTS', '') AS float) / 1000000").to_h
  end
  
  puts "Top #{limit} Rich List by #{symbol}"
  ap accounts
end
