module UploadJuicer
  def self.rails_init
    YAML::load(ERB.new(File.read(Rails.root.join('config', 'upload_juicer.yml'))).result)[Rails.env].each { |k, v| UploadJuicer::Config.send("#{k}=", v) } rescue nil
  end

  if defined?(::Rails::Railtie)
    class Railtie < ::Rails::Railtie
      config.after_initialize do |app|
        UploadJuicer.rails_init
      end
    end
  else
    rails_init
  end

end
