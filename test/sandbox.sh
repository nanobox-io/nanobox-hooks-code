#!/bin/bash
#
# Launch a container and console into it

test_dir="$(dirname $(readlink -f $BASH_SOURCE))"
payload_dir="$(readlink -f ${test_dir}/payloads)"
util_dir="$(readlink -f ${test_dir}/util)"
hookit_dir="$(readlink -f ${test_dir}/../src)"

# source the warehouse helpers
. ${util_dir}/warehouse.sh

# source the unfs helpers
. ${util_dir}/unfs.sh

# spawn a warehouse
echo "Launching a warehouse container..."
start_warehouse

# spawn a unfs component
echo "Launching a unfs container..."
start_unfs

# start a container for a sandbox
echo "Launching a sandbox container..."
docker run \
  --name=sandbox \
  -d \
  --privileged \
  --net=nanobox \
  --ip=192.168.0.55 \
  --volume=${hookit_dir}/:/opt/nanobox/hooks \
  --volume=${payload_dir}/:/payloads \
  nanobox/code

# hop into the sandbox
echo "Consoling into the sandbox..."
docker exec -it sandbox bash

# remove the sandbox
echo "Destroying the sandbox container..."
docker stop sandbox
docker rm sandbox

# remove the unfs
echo "Destroying the unfs containe..."
stop_unfs

# remove the warehouse
echo "Destroying the warehouse container..."
stop_warehouse

echo "Bye."
