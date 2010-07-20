module UploadsHelper
  def s3_post_params(options = {})
    acl = options[:acl] || 'public-read'
    expiration = options[:expiration] || 6.hours.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    max_filesize = options[:max_filesize] || 2.gigabyte

    policy = Base64.encode64(
      { 'expiration' => expiration,
        'conditions' => [
          {'bucket' => UploadJuicer::Config.s3['bucket']},
          ['starts-with', '$key', s3_key],
          {'acl' => acl},
          {'success_action_status' => '201'},
          ['starts-with', '$Filename', ''],
          ['content-length-range', 0, max_filesize]
        ]
      }.to_json)

    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), UploadJuicer::Config.s3['secret_access_key'], policy)).gsub("\n", "")

    {
      "key" => "#{s3_key}/${filename}",
      "AWSAccessKeyId" => "#{UploadJuicer::Config.s3['access_key_id']}",
      "acl" => "#{acl}",
      "policy" => "#{policy}",
      "signature" => "#{signature}",
      "success_action_status" => "201"
    }
  end
  
  def s3_key
    @s3_key ||= SecureRandom.hex(8).scan(/..../).join('/')
  end
  
  def s3_upload_url
    @s3_upload_url ||= "http://#{UploadJuicer::Config.s3['bucket']}.s3.amazonaws.com/"
  end
  
  def swfupload_params
    { :upload_url => s3_upload_url, :post_params => s3_post_params }.to_json.html_safe
  end
  
end