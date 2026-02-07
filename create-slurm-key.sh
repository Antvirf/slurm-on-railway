#!/bin/bash
set -e

mkdir -p /etc/slurm
dd if=/dev/random bs=1024 count=1 | base64 > /etc/slurm/slurm.key
chmod 600 /etc/slurm/slurm.key
