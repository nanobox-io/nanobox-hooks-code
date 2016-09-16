require 'socket'

module Nanobox
  class Logvac

    EMERG   = {syslog: 0, prefix: 'EMERGENCY:'}
    ALERT   = {syslog: 1, prefix: 'ALERT:'}
    CRIT    = {syslog: 2, prefix: 'CRITICAL:'}
    ERR     = {syslog: 3, prefix: 'ERROR:'}
    WARNING = {syslog: 4, prefix: 'WARNING:'}
    NOTICE  = {syslog: 5, prefix: 'NOTICE:'}
    INFO    = {syslog: 6, prefix: 'INFO:'}
    DEBUG   = {syslog: 7, prefix: 'DEBUG:'}

    def initialize(opts)
      @hostname = opts[:hostname] || 'localhost'
      @id = opts[:id]
      @host = opts[:host] || '127.0.0.1'
      @port = opts[:port] || 514
      @level = opts[:level] || Nanobox::Logvac::INFO
      @socket = ::UDPSocket.new
    end

    def puts(message='', level=@level, id=@id)
      # <%d%d>%s %s %s %s\n
      # server.stream_facility, server.stream_priority,
      # server.time, server.stream_id, id, body
      timestamp = Time.now.strftime("%b %d %T")
      header = "<8#{level[:syslog]}>#{timestamp} #{@hostname} #{id} #{level[:prefix]} "
      message.scan(/.{1,#{1024-header.size}}/).each do |part|
        final_message = "#{header}#{part}"
        @socket.send(final_message, 0, @host, @port)
      end
    end
  end
end