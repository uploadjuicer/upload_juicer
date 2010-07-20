require 'upload_juicer'

class UploadJuicer::Upload < ActiveRecord::Base
  set_table_name 'upload_juicer_uploads'
  
  belongs_to :uploadable, :polymorphic => :true
  
  def url(style = nil)
    "http://#{UploadJuicer::Config.s3['bucket']}.s3.amazonaws.com/#{s3_path(style)}"
  end
  
  def s3_url(style = nil)
    "s3://#{UploadJuicer::Config.s3['bucket']}/#{s3_path(style)}"
  end
  
  def s3_path(style = nil)
    style = style.to_s
    style << '/' unless style.blank? || style.ends_with?('/')
    "#{key}/#{style}#{file_name}"
  end
  
  # The outputs var goes from this:
  #     { :avatar => { :size => '40x40>' } } 
  #   to this:
  #     [ { :label => 'avatar', :size => '40x40>', :url => s3_url('avatar') } ]
  def juice_upload(outputs)
    output_array = outputs.collect {|style, opts| { :label => style.to_s, :url => s3_url(style) }.merge(opts) }
    UploadJuicer::Job.submit(UploadJuicer::Config.api_key, s3_url, output_array)
  end
end
