#!/bin/sh

echo "entry point running"
echo "Using user: "$USER_N

mkdir -p /home/$USER_N
chown  $USER_N:$USER_N /home/$USER_N

cp /root/.bashrc /home/$USER_N/.bashrc
chown  $USER_N:$USER_N /home/$USER_N/.bashrc

chown  $USER_N:$USER_N /workspace

. /root/.profile

# echo "screen"
# screen -d -m visdom

su $USER_N

exec "$@"