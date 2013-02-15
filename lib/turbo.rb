module Turbo
  class Key
    def self.access
      SiteConfig.s3_access_key_id
    end
  
    def self.secret
      SiteConfig.s3_secret_access_key
    end
  end
  
  class Queue
    attr_accessor :name, :queue
        
    def initialize(queue_name)
      self.name = queue_name
      self.queue = find_or_create(queue_name)
    end

    def send(message)
      queue.send_message(message)
    end
    
    def has_messages?
      queue.size != 0
    end
        
    def sqs
      Aws::Sqs.new(Key.access, Key.secret)
    end
    
    def find_or_create(queue_name)
      Aws::Sqs::Queue.create(sqs, queue_name, true)
    end
  end
end