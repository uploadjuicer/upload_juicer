class UploadJuicer::UploadsController < ApplicationController
  unloadable
  
  def create
    @upload = UploadJuicer::Upload.create(params.slice(:file_name, :size, :key))
    render :json => @upload
  end
end
