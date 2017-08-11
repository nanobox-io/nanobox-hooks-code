# source docker helpers
. util/docker.sh

@test "Start Container" {
  start_container
}

@test "Create engine start_cmds test script" {
  start_cmds_script="$(cat <<-END
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

  stop_cmds_script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

puts stop_cmds
END
)"

  stop_timeouts_script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

puts stop_timeouts
END
)"

  stop_forces_script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

puts stop_forces
END
)"

  cwds_script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

puts cwds
END
)"

  run docker exec code bash -c "echo \"${start_cmds_script}\" > /tmp/start_cmds_test"
  run docker exec code bash -c "chmod +x /tmp/start_cmds_test"
  run docker exec code bash -c " [ -f /tmp/start_cmds_test ] "
  [ "$status" -eq 0 ]

  run docker exec code bash -c "echo \"${stop_cmds_script}\" > /tmp/stop_cmds_test"
  run docker exec code bash -c "chmod +x /tmp/stop_cmds_test"
  run docker exec code bash -c " [ -f /tmp/stop_cmds_test ] "
  [ "$status" -eq 0 ]

  run docker exec code bash -c "echo \"${stop_timeouts_script}\" > /tmp/stop_timeouts_test"
  run docker exec code bash -c "chmod +x /tmp/stop_timeouts_test"
  run docker exec code bash -c " [ -f /tmp/stop_timeouts_test ] "
  [ "$status" -eq 0 ]

  run docker exec code bash -c "echo \"${stop_forces_script}\" > /tmp/stop_forces_test"
  run docker exec code bash -c "chmod +x /tmp/stop_forces_test"
  run docker exec code bash -c " [ -f /tmp/stop_forces_test ] "
  [ "$status" -eq 0 ]

  run docker exec code bash -c "echo \"${cwds_script}\" > /tmp/cwd_test"
  run docker exec code bash -c "chmod +x /tmp/cwd_test"
  run docker exec code bash -c " [ -f /tmp/cwd_test ] "
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

@test "test string stop commands" {
  payload='{"stop":"something"}'
  
  run docker exec code bash -c "/tmp/stop_cmds_test '$payload'"

  expected=$(cat <<-END
{:app=>"something"}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test hash stop commands" {
  payload='{"stop":{"this":"something","that":"another","other":"again"}}'
  
  run docker exec code bash -c "/tmp/stop_cmds_test '$payload'"

  expected=$(cat <<-END
{:this=>"something", :that=>"another", :other=>"again"}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test string stop timeouts" {
  payload='{"stop_timeout": 10}'
  
  run docker exec code bash -c "/tmp/stop_timeouts_test '$payload'"

  expected=$(cat <<-END
{:app=>10}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test hash stop timeouts" {
  payload='{"stop_timeout":{"this": 10,"that": 15,"other": 20}}'
  
  run docker exec code bash -c "/tmp/stop_timeouts_test '$payload'"

  expected=$(cat <<-END
{:this=>10, :that=>15, :other=>20}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test string stop forces" {
  payload='{"stop_force":true}'
  
  run docker exec code bash -c "/tmp/stop_forces_test '$payload'"

  expected=$(cat <<-END
{:app=>true}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test hash stop forces" {
  payload='{"stop_force":{"this":true,"that":false,"other":true}}'
  
  run docker exec code bash -c "/tmp/stop_forces_test '$payload'"

  expected=$(cat <<-END
{:this=>true, :that=>false, :other=>true}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test string cwd" {
  payload='{"cwd":"something"}'
  
  run docker exec code bash -c "/tmp/cwd_test '$payload'"

  expected=$(cat <<-END
{:app=>"something"}
END
)
  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test hash cwd" {
  payload='{"cwd":{"this":"something","that":"another","other":"again"}}'
  
  run docker exec code bash -c "/tmp/cwd_test '$payload'"

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