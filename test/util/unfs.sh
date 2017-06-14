# utilities and helpers for launching a unfs for writable storage

util_dir="$(dirname $(readlink -f $BASH_SOURCE))"

start_unfs() {
  # launch container
  docker run \
    --name=unfs \
    -d \
    --privileged \
    --net=nanobox \
    --ip=192.168.0.101 \
    nanobox/unfs

  # configure
  docker exec \
    unfs \
    /opt/nanobox/hooks/configure "$(unfs_configure_payload)"

  # start
  docker exec \
    unfs \
    /opt/nanobox/hooks/start "$(unfs_start_payload)"
}

restart_unfs() {
  # restart container
  docker restart unfs
}

stop_unfs() {
  # destroy container
  docker stop unfs
  docker rm unfs
}

unfs_configure_payload() {
  cat <<-END
{
  "logvac_host": "192.168.0.102",
  "platform": "local",
  "config": {
  },
  "member": {
    "local_ip": "192.168.0.101",
    "uid": 1,
    "role": "primary"
  },
  "component": {
    "name": "sad-snake",
    "uid": "unfs1",
    "id": "9097d0a7-7e02-4be5-bce1-3d7cb1189488"
  },
  "users": [

  ]
}
END
}

unfs_start_payload() {
  cat <<-END
{
  "config": {
  }
}
END
}
