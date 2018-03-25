desc 'Lists sum of transfers grouped by date, from, and to.'
task :transfers, [:minimum_amount, :symbol, :days_ago] do |t, args|
  now = Time.now.utc
  minimum_amount = (args[:minimum_amount] || '1000000').to_f
  symbol = (args[:symbol] || 'STEEM').upcase
  after_timestamp = now - ((args[:days_ago] || '30').to_i * 86400)
  
  # Only type: transfer; ignore savings, vestings
  transfers = SteemApi::Tx::Transfer.where(type: 'transfer')
  transfers = transfers.where('amount > ?', minimum_amount)
  transfers = transfers.where('amount_symbol = ?', symbol)
  transfers = transfers.where('timestamp > ?', after_timestamp)
  transfers = transfers.group('CAST(timestamp AS DATE)', :from, :to)
  transfers = transfers.order('cast_timestamp_as_date ASC')
  
  puts "Daily transfer sum over #{'%.3f' % minimum_amount} #{symbol} since #{after_timestamp} ..."
  ap transfers.sum(:amount)
end

