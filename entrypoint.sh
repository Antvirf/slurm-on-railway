#!/bin/bash
set -e

# Get current short hostname
export SLURM_HOSTNAME=$(hostname -s)

# Default proxy settings for local execution (same as host)
# These will be overwritten by client.sh when running locally
export SLURM_PROXY_HOST=${SLURM_PROXY_HOST:-$SLURM_HOSTNAME}
export SLURM_PROXY_PORT=${SLURM_PROXY_PORT:-6817}

echo "Generating slurm.conf for hostname: $SLURM_HOSTNAME"
envsubst < /etc/slurm/slurm.conf.template > /etc/slurm/slurm.conf

# Start slurmctld in the foreground
exec /bin/sbin/slurmctld -vvvv -D "$@"

