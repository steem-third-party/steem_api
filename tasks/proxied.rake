desc 'Lists proxied grouped by month.'
task :proxied, [:days_ago] do |t, args|
  now = Time.now.utc
  after_timestamp = now - ((args[:days_ago] || '7').to_i * 86400)
  
  proxied = SteemApi::Tx::AccountWitnessProxy
  proxied = proxied.where('timestamp > ?', after_timestamp)
  proxied = proxied.group("FORMAT(timestamp, 'yyyy-MM')", :proxy)
  proxied = proxied.order('format_timestamp_yyyy_mm ASC')
  
  puts "Daily proxied grouped by month since #{after_timestamp} ..."
  
  ap proxied.count(:all)
end
