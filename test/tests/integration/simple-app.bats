# source docker helpers
. util/helpers.sh
. util/warehouse.sh
. util/unfs.sh

@test "Start container" {
  start_container
}

@test "Start warehouse container" {
  
}

@test "Start unfs container" {

}

@test "Run fetch hook" {
  run run_hook "fetch" "$(payload user)"
}
