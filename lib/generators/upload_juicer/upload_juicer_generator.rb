class UploadJuicerGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  desc <<-EOD
    This generator creates a configuration and migration to use the API at 
    http://uploadjuicer.com in your Rails application.  If you signed up for
    Juicer via Heroku, use the --heroku option to have the API key loaded
    from your Heroku environment.  Otherwise, use the --api_key option to
    supply the API key you received after signing up at the Juicer site.

  EOD

  class_option :api_key, :type => :string, :desc => "Your Juicer API key"
  class_option :heroku, :type => :boolean, :desc => "Use the Heroku addon to provide your Juicer API key"
  
  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), '..', '..', '..', 'generators', 'upload_juicer', 'templates')
  end

  def self.next_migration_number(dirname)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
  
  def doit
    if !options[:api_key] && !options[:heroku] && !File.exists?(File.join('config', 'upload_juicer.yml'))
      puts "Please use --api-key or --heroku or create config/upload_juicer.yml"
      exit
    end
    migration_template 'migration.rb', File.join('db', 'migrate', 'create_upload_tables.rb')
    template 'config.yml', File.join('config', 'upload_juicer.yml')
    directory 'public'
  end
  
  private
  
    def api_key_fetcher
      options[:api_key] ? options[:api_key] : "<%= ENV['JUICER_API_KEY'] %>"
    end

end