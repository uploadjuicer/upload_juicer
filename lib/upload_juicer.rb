require 'json'
require 'rest_client'
require 'ostruct'

module UploadJuicer
  API_URL = 'http://app.uploadjuicer.com/jobs'
  VERSION = '0.9.2'
  
  Config = OpenStruct.new
  
  class Job
    def self.submit(api_key, url, outputs)
      JSON.parse(RestClient.post("#{UploadJuicer::API_URL}?token=#{api_key}&gem=#{UploadJuicer::VERSION}", 
        { :url => url, :outputs => outputs }.to_json, { :content_type => :json, :accept => :json }))
    end
    
    def self.info(api_key, id)
      JSON.parse(RestClient.get("#{UploadJuicer::API_URL}/#{id}?token=#{api_key}&gem=#{UploadJuicer::VERSION}",
        { :content_type => :json, :accept => :json }))
    end
  end
  
end

if defined?(Rails)
  require 'upload_juicer/extensions/string'
  require 'upload_juicer/railtie'
  require 'upload_juicer/engine'
end
