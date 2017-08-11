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

    # The ENV_DIR contains environment variables available to the
    # application in the live environment
    PROFILE_DIR = "#{DATA_DIR}/etc/profile.d"

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
      elsif payload[:start].is_a? Array
        cmds = {}
        payload[:start].each_index {|i|cmds[("app"+i.to_s).to_sym]=payload[:start][i]}
        cmds
      else # It's a string, so make it a hash
        {app: payload[:start]}
      end
    end

    def cwds
      if payload[:cwd]
        if payload[:cwd].is_a? Hash
          payload[:cwd]
        else # It's a string, so make it a hash
          {app: payload[:cwd]}
        end
      else
        {}
      end
    end

    def stop_cmds
      if payload[:stop]
        if payload[:stop].is_a? Hash
          payload[:stop]
        else # It's a string, so make it a hash
          {app: payload[:stop]}
        end
      else
        {}
      end
    end

    def stop_timeouts
      if payload[:stop_timeout]
        if payload[:stop_timeout].is_a? Hash
          payload[:stop_timeout]
        else # It's a string, so make it a hash
          {app: payload[:stop_timeout]}
        end
      else
        {}
      end
    end

    def stop_forces
      if payload[:stop_force]
        if payload[:stop_force].is_a? Hash
          payload[:stop_force]
        else # It's a string, so make it a hash
          {app: payload[:stop_force]}
        end
      else
        {}
      end
    end

    def run_deploy_hook(index, cmd, cuid, muid, type, logger, bubble=false)
      begin
        Timeout::timeout(payload[:hook_timeout] || 300) do
          logger.puts("Starting: #{cmd}", Nanobox::Logvac::INFO, "#{cuid}.#{muid}[#{type}#{index + 1}]")
          execute "#{type}#{index + 1}: #{cmd}" do
            command "siphon --prefix '' -- bash -i -l -c \"#{escape cmd}\""
            cwd APP_DIR
            user 'gonano'
            on_data {|data| logger.puts(data, Nanobox::Logvac::INFO, "#{cuid}.#{muid}[#{type}#{index + 1}]")}
          end
          logger.puts("Finished: #{cmd}", Nanobox::Logvac::INFO, "#{cuid}.#{muid}[#{type}#{index + 1}]")
        end
      rescue Hookit::Error::UnexpectedExit => e
        logger.puts("There was an unexpected exit from the deploy hook", Nanobox::Logvac::ERR, "#{cuid}.#{muid}[#{type}#{index + 1}]")
        raise e if bubble
      rescue Timeout::Error => e
        logger.puts("The hook took longer than expected to run", Nanobox::Logvac::ERR, "#{cuid}.#{muid}[#{type}#{index + 1}]")
        raise e if bubble
      end
    end

  end
end
