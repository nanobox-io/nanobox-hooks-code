# source docker helpers
. util/docker.sh

@test "Start Container" {
  start_container
}

@test "Create engine start_cmds test script" {
  script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

puts start_cmds
END
)"

  run docker exec code bash -c "echo \"${script}\" > /tmp/start_cmds_test"
  run docker exec code bash -c "chmod +x /tmp/start_cmds_test"
  run docker exec code bash -c " [ -f /tmp/start_cmds_test ] "

  [ "$status" -eq 0 ]
}

@test "test string start commands" {
  payload='{"start":"something"}'
  
  run docker exec code bash -c "/tmp/start_cmds_test '$payload'"

  expected=$(cat <<-END
{:app=>"something"}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test array of strings start commands" {
  payload='{"start":["something","another","again"]}'
  
  run docker exec code bash -c "/tmp/start_cmds_test '$payload'"

  expected=$(cat <<-END
{:app0=>"something", :app1=>"another", :app2=>"again"}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test hash start commands" {
  payload='{"start":{"this":"something","that":"another","other":"again"}}'
  
  run docker exec code bash -c "/tmp/start_cmds_test '$payload'"

  expected=$(cat <<-END
{:this=>"something", :that=>"another", :other=>"again"}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}