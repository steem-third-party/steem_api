# Doesn't look like this table exists.
desc 'List conversion SBD conversion request sums grouped by day.'
task :convert, [:days_ago] do |t, args|
  now = Time.now.utc
  after_timestamp = now - ((args[:days_ago] || '3.5').to_f * 86400)

  converts = SteemApi::Vo::FillConvertRequest
  converts = converts.where('timestamp > ?', after_timestamp)
  converts = converts.group('CAST(timestamp AS DATE)')
  converts = converts.order('cast_timestamp_as_date ASC')

  puts "Daily conversion requests failled sum grouped by date since #{after_timestamp} ..."
  ap converts.sum(:amount)
end
