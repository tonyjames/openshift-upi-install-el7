#!/usr/bin/env bash

function exit_on_failure() {
  echo "Exiting due to error..."
  exit
}

sudo subscription-manager register

if [ $? == 0 ]; then
  sudo subscription-manager repos \
    --disable=* \
    --enable=rhel-7-server-rpms \
    --enable=rhel-7-server-extras-rpms \
    --enable=rhel-7-server-ansible-2.9-rpms || exit_on_failure
fi

echo "Updating packages..."
sudo yum update -y --quiet

echo "Installing dependencies..."
sudo yum install -y --quiet \
  ansible \
  bash-completion \
  httpd \
  podman \
  python2-cryptography

echo "Enabling httpd service..."
sudo systemctl enable --now httpd

echo "Installing ansible collections..."
ansible-galaxy collection install containers.podman
