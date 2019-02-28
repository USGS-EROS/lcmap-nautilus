#!/bin/sh

# Docker image name
image=nautilus

# Nautilus version
version=0.1.10-develop

# Environment file location
envfile=.env

# Mounts
notebooks=/notebooks
certs=/certs
data=/data

docker run -it --rm --name $image --net=host --env-file=$envfile -v $notebooks:/notebooks -v $certs:/certs -v $data:/data usgseros/lcmap-nautilus:$version `id -u` `id -un`
