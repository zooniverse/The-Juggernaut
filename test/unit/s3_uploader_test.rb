require 'test_helper'

class S3UploaderTest < ActiveSupport::TestCase
  context "The S3Uploader" do
    should "have class methods" do
      assert S3Uploader.respond_to?(:upload_subject)
      assert S3Uploader.respond_to?(:s3_connect)
      assert S3Uploader.respond_to?(:suffix_for_file)      
    end
  end
  
  context "The S3Uploader" do
    setup do
      @text_file = File.new("#{ Rails.root }/test/fixtures/test_file.txt")
      @png_file = File.new("#{ Rails.root }/test/fixtures/jugg.png")
      @pdf_file = File.new("#{ Rails.root }/test/fixtures/jugg.pdf")
      @zip_file = File.new("#{ Rails.root }/test/fixtures/jugg.png.zip")
      @gif_file = File.new("#{ Rails.root }/test/fixtures/jugg.gif")
      @tar_file = File.new("#{ Rails.root }/test/fixtures/jugg.tar")
      @gz_file = File.new("#{ Rails.root }/test/fixtures/jugg.png.gz")
      @jpg_file = File.new("#{ Rails.root }/test/fixtures/jugg.jpg")
      @tgz_file = File.new("#{ Rails.root }/test/fixtures/jugg.tgz")
    end

    should "detect content type and assign correct suffix" do
      assert_equal S3Uploader.suffix_for_file(@text_file), "txt"
      assert_equal S3Uploader.suffix_for_file(@png_file), "png"
      assert_equal S3Uploader.suffix_for_file(@pdf_file), "pdf"
      assert_equal S3Uploader.suffix_for_file(@zip_file), "zip"
      assert_equal S3Uploader.suffix_for_file(@gif_file), "gif"
      assert_equal S3Uploader.suffix_for_file(@tar_file), "tar"
      assert_equal S3Uploader.suffix_for_file(@gz_file), "gz"
      assert_equal S3Uploader.suffix_for_file(@jpg_file), "jpg"
      assert_equal S3Uploader.suffix_for_file(@tgz_file), "gz"
    end
  end
  
  context "When uploading a valid file" do
    setup do
      AWS::S3::Base.stubs(:establish_connection!).returns(:true)
      AWS::S3::S3Object.stubs(:store).returns(true)
      SiteConfig.stubs(:s3_subjects_bucket).returns('test_bucket')
      @subject = Factory :subject, :location => ""
      @subject.expects(:save).once
      @png_file = File.new("#{ Rails.root }/test/fixtures/jugg.png")      
      S3Uploader.upload_subject(@png_file, @subject)
    end

    should "upload and set location" do
      assert_equal @subject.location, "http://s3.amazonaws.com/test_bucket/#{ @subject.id }.png"
    end
  end
  
  context "When uploading a with an AWS response error" do
    setup do
      AWS::S3::Base.stubs(:establish_connection!).returns(:true)
      AWS::S3::S3Object.stubs(:store).raises(AWS::S3::ResponseError)
      @subject = Factory :subject, :location => ""
      @subject.expects(:save).never
    end
    
    should "respond with false" do
      assert !@uploader_response
    end

    should "not set location" do
      assert_equal @subject.location, ""
    end
  end
end