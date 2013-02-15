url = "#{ SiteConfig.api_url }/classifications"
queue_name = SiteConfig.sqs_queue
turbo_queue = Turbo::Queue.new(queue_name)

loop do
  if turbo_queue.has_messages?
    sqs = turbo_queue.queue
    current_size = sqs.size
    
    10.times do
      message = sqs.pop
          
      unless message.nil?
        log(:info, "Processing 1 of #{ current_size } classifications")
        
        resource = RestClient::Resource.new(url, :headers => { :accept => "application/xml", :content_type => "application/xml" })
        begin
         resource.post(message.to_s)
        rescue RestClient::Exception => e
          log(:error, "Message POST deilvery failed: #{ e.to_s }")
        else
          log(:info, "SQS message successfully processed")
        end
      end
    end
  end
  
  sleep 3
end


def log(level, message)
  ActiveRecord::Base.logger.send(level, message)  
end