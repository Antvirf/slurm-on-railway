#!/bin/bash
set -e

# Get current short hostname
CURRENT_HOSTNAME=$(hostname -s)

echo "Updating slurm.conf with hostname: $CURRENT_HOSTNAME"

# Update SlurmctldHost and NodeName to match the current container hostname
sed -i "s/^SlurmctldHost=.*/SlurmctldHost=$CURRENT_HOSTNAME/" /etc/slurm/slurm.conf
#sed -i "s/^NodeName=.*/NodeName=$CURRENT_HOSTNAME State=UNKNOWN/" /etc/slurm/slurm.conf
#sed -i "s/^PartitionName=debug Nodes=.*/PartitionName=debug Nodes=$CURRENT_HOSTNAME Default=YES MaxTime=INFINITE State=UP/" /etc/slurm/slurm.conf

# Start slurmctld in the foreground
exec /bin/sbin/slurmctld -D "$@"
