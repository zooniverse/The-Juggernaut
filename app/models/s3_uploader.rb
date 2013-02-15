class S3Uploader
  def self.upload_subject(incoming, subject)
    s3_connect
    begin
      suffix = suffix_for_file(incoming)
      name = "#{ subject.id }.#{ suffix }"
      upload = AWS::S3::S3Object.store(
        name,
        incoming.read,
        "#{ SiteConfig.s3_subjects_bucket }",
        :content_type => File.mime_type?(incoming),
        :access => :public_read 
      )
      subject.location = "http://s3.amazonaws.com/#{ SiteConfig.s3_subjects_bucket }/#{ name }"
      subject.save
      uploaded = true
    rescue AWS::S3::ResponseError
      uploaded = false
    end
    uploaded
  end
  
  def self.s3_connect
    AWS::S3::Base.establish_connection!(
      :access_key_id     => "#{ SiteConfig.s3_access_key_id }",
      :secret_access_key => "#{ SiteConfig.s3_secret_access_key }"
    )
  end
  
  def self.suffix_for_file(incoming)
    content_type = File.mime_type?(incoming)
    if content_type.include?('application/pdf')
      suffix = 'pdf'
    elsif content_type.include?('text/plain')
      suffix = 'txt'
    elsif content_type.include?('application/x-zip-compressed') || content_type.include?('multipart/x-zip') || content_type.include?('application/zip')
      suffix = 'zip'
    elsif content_type.include?('application/x-tar')
      suffix = 'tar'
    elsif content_type.include?('application/x-gzip')
      suffix = 'gz'
    elsif content_type.include?('image/jpeg')
      suffix = 'jpg'
    elsif content_type.include?('image/gif')
      suffix = 'gif'
    elsif content_type.include?('image/png')
      suffix = 'png'
    end
  end
end