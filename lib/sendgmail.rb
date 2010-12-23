require 'tmail'
require 'tlsmail'

module SendGmail #:nodoc:
  class Config
    # Gmail account
    attr_accessor :account
    # Gmail password
    attr_accessor :password
    # Gmail smtp_domain
    attr_accessor :smtp_domain
    # Gmail smtp_port
    attr_accessor :smtp_port

    def initialize(&block)
      block.call(self)
    end
  end

  class Client
    SMTP_DOMAIN  = "smtp.gmail.com"
    SMTP_PORT    = 587
    DEFAULT_DATE = Time.now
    DEFAULT_MIME_VESION = "1.0"

    # creates a new Gmail client instance.
    #
    #   SendGmail::Client.new do |c|
    #     c.account = "your.address@gmail.com"
    #     c.password = "yourpassword"
    #   end
    #
    def initialize(args = {}, &block)
      @config = Config.new do |c|
        c.account = args[:account]
        c.password = args[:password] 
        c.smtp_domain = args[:smtp_domain] ||= SMTP_DOMAIN
        c.smtp_port = args[:smtp_port] ||= SMTP_PORT
      end
      if block_given?
        block.call @config
      end
    end
  
    # send your mail from Gmail.
    #
    #   client.send(
    #     :to   => 'foo.bar@gmail.com',
    #     :from => 'your.address@gmail.com',
    #     :subject => 'hello',
    #     :body    => 'world'
    #   end
    #
    def send(params = {})
      mail = create_mail(params)

      ::Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      ::Net::SMTP.start(
        @config.smtp_domain,
        @config.smtp_port,
        "localhost.localdomain",
        @config.account,
        @config.password,
        "plain"){ |smtp| 
        smtp.sendmail(mail.encoded, mail.from, mail.to) 
      }
    end
  
    def create_mail(params ={})
      mail         = ::TMail::Mail.new
      mail.to      = params[:to]
      mail.from    = params[:from]
      mail.subject = params[:subject]
      mail.date    = params[:date] ||= DEFAULT_DATE
      mail.mime_version = params[:mime_version] ||= DEFAULT_MIME_VESION
      mail.set_content_type 'text', 'plain', {'charset'=>'iso-2022-jp'}
      mail.body    = params[:body]
      return mail
    end
  
  end
end