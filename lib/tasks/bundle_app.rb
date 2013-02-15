desc 'Bundle application to S3'
task :bundle_app => :environment do
  puts 'Bundling application to S3'
  `git archive -o juggernaut.tar HEAD`
  `gzip juggernaut.tar`
  
  require 'rubygems'
  require 'aws/s3'
  AWS::S3::Base.establish_connection!(
    :access_key_id     => SiteConfig.s3_access_key_id,
    :secret_access_key => SiteConfig.s3_secret_access_key
  )
  
  # upload the new one
  print 'Uploading new one...'
  AWS::S3::S3Object.store('juggernaut_new.tar.gz', open('juggernaut.tar.gz'), 'AWS-BUCKET')
  puts 'done'
  
  # rename the old file
  puts 'Renaming old code bundle'
  AWS::S3::S3Object.rename 'juggernaut.tar.gz', "juggernaut-#{ Time.now.strftime('%H%M-%d%m%y') }.tar.gz", 'AWS-BUCKET'
  
  # rename the new file
  AWS::S3::S3Object.rename 'juggernaut_new.tar.gz', 'juggernaut.tar.gz', 'AWS-BUCKET'
  
  puts 'Cleaning up'
  `rm juggernaut.tar.gz`
  puts 'Done'
end
