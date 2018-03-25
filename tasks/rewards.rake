namespace :rewards do
  desc 'Lists author rewards grouped by date.'
  task :author, [:symbol, :days_ago] do |t, args|
    now = Time.now.utc
    symbol = (args[:symbol] || 'SBD').upcase
    after_timestamp = now - ((args[:days_ago] || '7').to_i * 86400)
    
    rewards = SteemApi::Vo::AuthorReward
    rewards = rewards.where('timestamp > ?', after_timestamp)
    rewards = rewards.group('CAST(timestamp AS DATE)')
    rewards = rewards.order('cast_timestamp_as_date ASC')
    
    puts "Daily author reward #{symbol} sum grouped by date since #{after_timestamp} ..."
    
    case symbol
    when 'SBD' then ap rewards.sum(:sdb_payout)
    when 'STEEM' then ap rewards.sum(:steem_payout)
    when 'VESTS' then ap rewards.sum(:vesting_payout)
    when 'MVESTS'
      ap rewards.sum('vesting_payout / 1000000')
    else; puts "Unknown symbol: #{symbol}.  Symbols supported: SBD, STEEM, VESTS, MVESTS"
    end
  end

  desc 'Lists curation rewards grouped by date.'
  task :curation, [:symbol, :days_ago] do |t, args|
    now = Time.now.utc
    symbol = (args[:symbol] || 'MVESTS').upcase
    after_timestamp = now - ((args[:days_ago] || '7').to_i * 86400)
    
    rewards = SteemApi::Vo::CurationReward
    rewards = rewards.where('timestamp > ?', after_timestamp)
    rewards = rewards.group('CAST(timestamp AS DATE)')
    rewards = rewards.order('cast_timestamp_as_date ASC')
    
    puts "Daily curation reward #{symbol} sum grouped by date since #{after_timestamp} ..."
    
    case symbol
    when 'VESTS'
      ap rewards.sum("TRY_PARSE(REPLACE(reward, ' VESTS', '') AS float)")
    when 'MVESTS'
      ap rewards.sum("TRY_PARSE(REPLACE(reward, ' VESTS', '') AS float) / 1000000")
    else; puts "Unknown symbol: #{symbol}.  Symbols supported: VESTS, MVESTS"
    end
  end
  
  desc 'Lists benefactor rewards grouped by date.'
  task :benefactor, [:symbol, :days_ago] do |t, args|
    now = Time.now.utc
    symbol = (args[:symbol] || 'MVESTS').upcase
    after_timestamp = now - ((args[:days_ago] || '7').to_i * 86400)
    
    rewards = SteemApi::Vo::CommentBenefactorReward
    rewards = rewards.where('timestamp > ?', after_timestamp)
    rewards = rewards.group('CAST(timestamp AS DATE)')
    rewards = rewards.order('cast_timestamp_as_date ASC')
    
    puts "Daily benefactor reward #{symbol} sum grouped by date since #{after_timestamp} ..."
    
    case symbol
    when 'VESTS'
      ap rewards.sum("TRY_PARSE(REPLACE(reward, ' VESTS', '') AS float)")
    when 'MVESTS'
      ap rewards.sum("TRY_PARSE(REPLACE(reward, ' VESTS', '') AS float) / 1000000")
    else; puts "Unknown symbol: #{symbol}.  Symbols supported: VESTS, MVESTS"
    end
  end
end
