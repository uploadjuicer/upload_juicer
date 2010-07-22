class UploadJuicerGenerator < Rails::Generator::Base
  def add_options!(opt)
    opt.on('-k', '--api-key=key', String, "Your Juicer API key")                                 {|v| options[:api_key] = v}
    opt.on('-h', '--heroku',              "Use the Heroku addon to provide your Juicer API key") {|v| options[:heroku]  = v}
  end

  def manifest
    if !options[:api_key] && !options[:heroku] && !File.exists?(File.join('config', 'upload_juicer.yml'))
      puts "Please use --api-key or --heroku or create config/upload_juicer.yml"
      exit
    end

    record do |m|
      m.migration_template "migration.rb", File.join('db', 'migrate'), :migration_file_name => 'create_upload_tables'
      m.template "config.yml", File.join('config', 'upload_juicer.yml'), :assigns => { :api_key => api_key_fetcher }

      m.directory "public/images/swfupload"
      m.directory "public/javascripts"
      m.directory "public/stylesheets"
      
      full_path = source_path("public")
      Dir[source_path("public") + "/**/**/*.*"].each do |file|
        m.file file.gsub(full_path, 'public'), file.gsub(full_path, 'public')
      end
    end
  end

  def api_key_fetcher
    options[:api_key] ? options[:api_key] : "<%= ENV['JUICER_API_KEY'] %>"
  end

end
