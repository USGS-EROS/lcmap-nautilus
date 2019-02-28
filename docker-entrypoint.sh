#!/bin/bash

# Default to the built-in lcmap user for step-down.
uid=${1:-1000}
usern=${2:-"lcmap"}
gid=${3:-100}
groupn=${4:-"users"}

# Could if out everything, but let's let the user assume some responsibility (what could go wrong?).

# What could go wrong?
if [ ${groupn} = "users" -a ${gid} != 100 ]; then
  echo "Changing group name to avoid conflict"
  gname="somegroup"
fi

# Different group permissions.
if [ ${gid} != 100 ]; then
  echo "Adding group ${groupn} ${gid}"
  groupadd -f --gid=${gid} "${groupn}"
fi

# Modify lcmap user, name is not important.
if [ ${uid} != 1000 -a ${usern} = "lcmap" ]; then
  echo "Modifying lcmap user"
  usermod --gid=${gid} --uid=${uid} --login="${usern}" lcmap
fi

# Add unique user to step-down to.
if [ ${uid} != 1000 -a ${usern} != "lcmap" ]; then
  echo "Adding new user to container"
  useradd -r -m -g ${gid} --uid=${uid} "${usern}"
fi

# Pertinent environment variables related to the user.
export HOME=/home/"${usern}"
export USER="${usern}"
cd ~

echo "Stepping down to ${usern}"
exec gosu ${usern} "/bin/bash"
