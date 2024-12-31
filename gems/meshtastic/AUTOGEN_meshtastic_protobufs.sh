#!/bin/bash --login
mesh_root='/opt/meshtastic'
mesh_protobufs_root="${mesh_root}/protobufs"
mesh_protobufs_out='/opt/meshtastic/lib'

sudo apt install protobuf-compiler

mkdir -p $mesh_protobufs_out

if [[ ! -d $mesh_root ]]; then
  sudo mkdir -p $mesh_root
  sudo chown $USER:$USER $mesh_root
fi

cd $mesh_root
if [[ ! -d $mesh_protobufs_root ]]; then
  sudo git clone https://github.com/meshtastic/protobufs
fi

cd $mesh_protobufs_root
sudo protoc --proto_path=. --ruby_out=$mesh_protobufs_out nanopb.proto ./meshtastic/*.proto

if (( $? == 0 )); then
  echo "Updated meshtastic protobufs reside in ${mesh_protobufs_out}"
fi
