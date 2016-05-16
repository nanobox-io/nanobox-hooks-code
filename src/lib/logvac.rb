require 'remote_syslog_logger'
require 'logger'

module NanoBox
  class Logvac
    
    def initialize(opts)
      @id = opts[:id]
      @host = opts[:host] || '127.0.0.1'
      @logger = RemoteSyslogLogger.new(@host, 514)
      @logger.level = Logger::INFO
    end

    def puts(message='', level=Logger::INFO, id=@id)
      @logger.add(level, message, id)
    end

  end
end