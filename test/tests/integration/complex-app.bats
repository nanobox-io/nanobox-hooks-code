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
  run run_hook "fetch" "$(payload fetch)"
  echo "$output"
  [ "$status" -eq 0 ]

  logvac_check_logs "Retrieving application"

  # verify deploy was downloaded and extracted
  run docker exec code bash -c "[ -f /data/bin/node ]"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify app was downloaded and extracted
  run docker exec code bash -c "[ -f /app/server.js ]"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify second run doesn't break things
  run run_hook "fetch" "$(payload fetch)"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run configure hook" {
  run run_hook "configure" "$(payload configure)"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify second run doesn't break things
  run run_hook "configure" "$(payload configure)"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run start hook" {
  run run_hook "start" "$(payload start-stop-cmd)"
  echo "$output"
  [ "$status" -eq 0 ]

  logvac_check_logs "Starting app: node server.js"

  # verify the app is running
  run docker exec code bash -c "curl http://127.0.0.1:8080 2>/dev/null"
  echo "$output"
  [ "$output" = "Node.js - Express - Hello World!" ]

  run docker exec code bash -c "[ -f /etc/service/app/control/d ]"
  echo "$output"
  [ "$status" -eq 0 ]

  # verify second run doesn't break things
  run run_hook "start" "$(payload start-stop-cmd)"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run before deploy hook" {
  run run_hook "before_live" "$(payload before_live)"
  echo "$output"
  [ "$status" -eq 0 ]

  logvac_check_logs "Finished: echo 'before deploy all 2'"

  # verify second run doesn't break things
  run run_hook "before_live" "$(payload before_live)"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run after deploy hook" {
  run run_hook "after_live" "$(payload after_live)"
  echo "$output"
  [ "$status" -eq 0 ]

  logvac_check_logs "Finished: echo 'after deploy all 2'"

  # verify second run doesn't break things
  run run_hook "after_live" "$(payload after_live)"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "Run stop hook" {
  run run_hook "stop" "$(payload stop-force)"
  echo "$output"
  [ "$status" -eq 0 ]

  # wait a few seconds to be sure
  sleep 3

  # verify the app is not running
  run docker exec code bash -c "ps aux | grep [n]ode"
  echo "$output"
  [ "$status" -ne 0 ]

  # test double calling the stop hook
  run run_hook "stop" "$(payload stop-force)"
  echo "$output"
  [ "$status" -eq 0 ]
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
