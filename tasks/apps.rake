desc 'Lists apps grouped by date, app/version.'
task :apps, [:app, :days_ago] do |t, args|
  now = Time.now.utc
  app = args[:app]
  after_timestamp = now - ((args[:days_ago] || '7').to_i * 86400)
  
  comments = SteemApi::Comment.normalized_json
  comments = comments.app(app) if !!app
  comments = comments.where('created > ?', after_timestamp)
  comments = comments.group('CAST(created AS DATE)', "JSON_VALUE(json_metadata, '$.app')")
  comments = comments.order('cast_created_as_date ASC')
  
  matching = " matching \"#{app}\"" if !!app
  puts "Daily app#{matching} count since #{after_timestamp} ..."
  ap comments.count(:all)
end
