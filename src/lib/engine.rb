# Hook order:
#   1 - update
#   2 - fetch
#   3 - configure
#   4 - start
#   5 - stop

module Nanobox
  module Engine
    # The DATA_DIR is the pkgsrc build root. This is where pkgsrc is
    # bootstrapped and contains a fully chrooted environment that packages can
    # be installed into and binaries can be linked.
    DATA_DIR = '/data'

    # The ETC_DIR contains configuration for runtimes such as apache or nginx
    # that are required for the live environment.
    ETC_DIR = "#{DATA_DIR}/etc"

    # The ENV_DIR contains environment variables available to the
    # application in the live environment
    ENV_DIR = "#{DATA_DIR}/etc/env.d"

    # The APP_DIR contains the compiled app
    APP_DIR = '/app'

    GONANO_PATH = [
      "#{DATA_DIR}/sbin",
      "#{DATA_DIR}/bin",
      '/opt/gonano/sbin',
      '/opt/gonano/bin',
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin'
    ].join (':')


    def start_cmds
      if payload[:start].is_a? Hash
        payload[:start]
      else
        {app: payload[:start]}
      end
    end

  end
end
