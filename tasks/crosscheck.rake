desc 'Do all crosschecks of given account.'
task :crosscheck, [:account] do |t, args|
  account = args[:account]
    
  Rake::Task["crosscheck:powerdowns"].invoke(account)
  Rake::Task["crosscheck:powerups"].invoke(account)
  Rake::Task["crosscheck:transfers"].invoke(account)
  Rake::Task["crosscheck:vesting_from"].invoke(account)
  Rake::Task["crosscheck:vesting_to"].invoke(account)
end
  
namespace :crosscheck do
  desc 'List of accounts grouped by transfer count crosschecked by memo of given account.'
  task :transfers, [:account] do |t, args|
    exchanges = %w(bittrex poloniex openledger blocktrades)
    account = args[:account]
    
    if account.nil? || account == ''
      puts 'Account name required.'
      exit
    elsif exchanges.include? account
      puts 'That procedure is not recommended.'
      exit
    end
    
    all = SteemApi::Tx::Transfer.where(type: 'transfer')
    transfers = all.where(to: exchanges)
    transfers = if account =~ /%/
      table = SteemApi::Tx::Transfer.arel_table
      transfers.where(table[:from].matches(account))
    else
      transfers.where(from: account)
    end
    crosscheck_transfers = all.where(memo: transfers.select(:memo))
    
    if transfers.none?
      puts "No match."
    else
      from = transfers.pluck(:from).uniq.join(', ')
      puts "Accounts grouped by transfer count using common memos as #{from} on common exchanges ..."
      ap crosscheck_transfers.group(:from).order('count_all').count(:all)
    end
  end
  
  desc 'List of accounts grouped by vesting transfers from a given account'
  task :vesting_from, [:account] do |t, args|
    account = args[:account]
    
    if account.nil? || account == ''
      puts 'Account name required.'
      exit
    end
    
    table = SteemApi::Tx::Transfer.arel_table
    all = SteemApi::Tx::Transfer.where(type: 'transfer_to_vesting')
    transfers = all.where(table[:from].not_eq(:to))
    transfers = transfers.where.not(to: '')
    transfers = if account =~ /%/
      table = SteemApi::Tx::Transfer.arel_table
      transfers.where(table[:from].matches(account))
    else
      transfers.where(from: account)
    end
    
    if transfers.none?
      puts "No match."
    else
      from = transfers.pluck(:from).uniq.join(', ')
      puts "Accounts grouped by vesting transfer count from #{from} ..."
      ap transfers.group(:to).order('count_all').count(:all)
    end
  end
  
  desc 'List of accounts grouped by vesting transfers to a given account'
  task :vesting_to, [:account] do |t, args|
    account = args[:account]
    
    if account.nil? || account == ''
      puts 'Account name required.'
      exit
    end
    
    table = SteemApi::Tx::Transfer.arel_table
    all = SteemApi::Tx::Transfer.where(type: 'transfer_to_vesting')
    transfers = all.where(table[:from].not_eq(table[:to]))
    transfers = transfers.where.not(to: '')
    transfers = if account =~ /%/
      table = SteemApi::Tx::Transfer.arel_table
      transfers.where(table[:to].matches(account))
    else
      transfers.where(to: account)
    end
    
    if transfers.none?
      puts "No match."
    else
      from = transfers.pluck(:to).uniq.join(', ')
      puts "Accounts grouped by vesting transfer count to #{from} ..."
      ap transfers.group(:from).order('count_all').count(:all)
    end
  end
  
  desc 'List of accounts grouped by powerdown sums crosschecked by given account.'
  task :powerdowns, [:account] do |t, args|
    account = args[:account]
    
    if account.nil? || account == ''
      puts 'Account name required.'
      exit
    end
    
    table = SteemApi::Vo::FillVestingWithdraw.arel_table
    all = SteemApi::Vo::FillVestingWithdraw.where(table[:from_account].not_eq(table[:to_account]))
    powerdowns = if account =~ /%/
      all.where(table[:from_account].matches(account))
    else
      all.where(from_account: account)
    end
    
    if powerdowns.none?
      puts "No match."
    else
      from = powerdowns.pluck(:from_account).uniq.join(', ')
      puts "Powerdowns grouped by sum from #{from} ..."
      ap powerdowns.group(:to_account).
        order('sum_try_parse_replace_withdrawn_vests_as_float').
        sum("TRY_PARSE(REPLACE(withdrawn, ' VESTS', '') AS float)")
    end
  end
  
  desc 'List of accounts grouped by powerup sums crosschecked by given account.'
  task :powerups, [:account] do |t, args|
    account = args[:account]
    
    if account.nil? || account == ''
      puts 'Account name required.'
      exit
    end
    
    table = SteemApi::Vo::FillVestingWithdraw.arel_table
    all = SteemApi::Vo::FillVestingWithdraw.where(table[:from_account].not_eq(table[:to_account]))
    powerups = if account =~ /%/
      all.where(table[:to_account].matches(account))
    else
      all.where(to_account: account)
    end
    
    if powerups.none?
      puts "No match."
    else
      to = powerups.pluck(:to_account).uniq.join(', ')
      puts "Powerups grouped by sum to #{to} ..."
      ap powerups.group(:from_account).
        order('sum_try_parse_replace_withdrawn_vests_as_float').
        sum("TRY_PARSE(REPLACE(withdrawn, ' VESTS', '') AS float)")
    end
  end
end
