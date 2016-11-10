# source docker helpers
. util/docker.sh
. util/warehouse.sh
. util/unfs.sh
. util/logvac.sh
. util/mist.sh

@test "Start container" {
  start_container
}

@test "Start mist container" {
  start_mist
}

@test "Start logvac container" {
  start_logvac
}

@test "Start warehouse container" {
  start_warehouse
}

@test "Start unfs container" {
  start_unfs
}

@test "Run fetch hook" {
  run run_hook "fetch" "$(payload fetch-no-logvac)"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify deploy was downloaded and extracted
  run docker exec code bash -c "[ -f /data/bin/node ]"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify app was downloaded and extracted
  run docker exec code bash -c "[ -f /app/server.js ]"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run configure hook" {
  run run_hook "configure" "$(payload configure-no-logvac)"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify environment variables
  run docker exec code bash -c "cat /data/etc/env.d/APP_NAME"
  echo "$output"
  [ "$output" = "slippery-sloth" ]

  # verify transformations were run
  run docker exec code bash -c "cat /app/test-transform.txt"
  echo "$output"
  [ "$output" = "slippery-sloth" ]

  # ensure app is not writable
  run docker exec code bash -c "[ ! -w /app/server.js ]"
  echo "$output"
  [ "$status" -eq 1 ]

  # ensure writable dirs are writable
  run docker exec code bash -c "ls -lah /app/node_modules/express/lib/application.js | grep \"rw-r--r--\""
  echo "$output"
  [ "$status" -eq 0 ]

  # ensure log_watches are writable
  run docker exec code bash -c "ls -lah /app/path/to/error.log | grep \"rw-r--r--\""
  echo "$output"
  [ "$status" -eq 0 ]

  # verify mounts
  run docker exec code bash -c "mount | grep foo/bar"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify cron
  run docker exec code bash -c "ls /opt/nanobox"
  [[ $output =~ cron ]]
}

@test "Run start hook" {
  run run_hook "start" "$(payload start-no-logvac)"
  echo "$output"
  [ "$status" -eq 0 ]

  sleep 5

  # verify the app is running
  run docker exec code bash -c "curl http://127.0.0.1:8080 2>/dev/null"
  echo "$output"
  [ "$output" = "Node.js - Express - Hello World!" ]
}

@test "Run before deploy hook" {
  run run_hook "before_deploy" "$(payload before_deploy-no-logvac)"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run after deploy hook" {
  run run_hook "after_deploy" "$(payload after_deploy-no-logvac)"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run stop hook" {
  run run_hook "stop" "$(payload stop-no-logvac)"
  echo "$output"
  [ "$status" -eq 0 ]

  # wait a few seconds to be sure
  sleep 3

  # verify the app is not running
  run docker exec code bash -c "ps aux | grep [n]ode"
  echo "$output"
  [ "$status" -ne 0 ]
}

@test "Stop container" {
  stop_container
}

@test "Stop warehouse container" {
  stop_warehouse
}

@test "Stop unfs container" {
  stop_unfs
}

@test "Stop logvac container" {
  stop_logvac
}

@test "Stop mist container" {
  stop_mist
}
