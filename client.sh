#!/bin/bash
set -e

# Load Railway configuration
if [ -f "railway.env" ]; then
    source railway.env
else
    echo "Error: railway.env not found. Copy railway.env.example and fill in your IDs."
    exit 1
fi

if [ -z "$RAILWAY_PROJECT_ID" ]; then
    echo "Error: RAILWAY_PROJECT_ID is not set in railway.env."
    exit 1
fi

echo "Using Project: $RAILWAY_PROJECT_ID"
echo "Using Environment: $RAILWAY_ENVIRONMENT_ID"
echo "Using Service: $RAILWAY_SERVICE_ID"

if [ -z "$1" ]; then
    echo "Usage: $0 <proxy-domain:port> [command]"
    echo "Example: $0 caboose.proxy.rlwy.net:53288 sinfo -N"
    exit 1
fi

PROXY_ADDR=$1
shift # Remove proxy from args, leaving the slurm command
CMD=$@

export SLURM_PROXY_HOST=$(echo $PROXY_ADDR | cut -d':' -f1)
export SLURM_PROXY_PORT=$(echo $PROXY_ADDR | cut -d':' -f2)

echo "--- Building Local Slurm Image ---"
docker build -q -t slurm-railway .

echo "--- Syncing with Railway ---"
export SLURM_HOSTNAME=$(railway ssh --project=$RAILWAY_PROJECT_ID --environment=$RAILWAY_ENVIRONMENT_ID --service=$RAILWAY_SERVICE_ID "hostname -s" | tr -d '\r' | tail -n 1)
echo "Remote hostname detected: $SLURM_HOSTNAME"

# Fetch slurm.key using base64 so we don't get bad line endings
railway ssh --project=$RAILWAY_PROJECT_ID --environment=$RAILWAY_ENVIRONMENT_ID --service=$RAILWAY_SERVICE_ID "base64 -w 0 /etc/slurm/slurm.key" | tr -d '\r' | tail -n 1 | base64 -d > ./railway-slurm.key
chmod 600 ./railway-slurm.key

# Generate the config from template
envsubst < slurm.conf.template > ./railway-slurm.conf

echo "--- Launching Client Container ---"
WRAPPED_CMD="mkdir -p /run/slurm && /bin/sbin/sackd -f /etc/slurm/slurm.conf & sleep 0.5 && "

if [ -z "$CMD" ]; then
    echo "No command provided, starting interactive shell..."
    docker run -it --rm \
        -v $(pwd)/railway-slurm.conf:/etc/slurm/slurm.conf \
        -v $(pwd)/railway-slurm.key:/etc/slurm/slurm.key \
        --entrypoint /bin/bash \
        slurm-railway -c "$WRAPPED_CMD bash"
else
    docker run --rm \
        -v $(pwd)/railway-slurm.conf:/etc/slurm/slurm.conf \
        -v $(pwd)/railway-slurm.key:/etc/slurm/slurm.key \
        --entrypoint /bin/bash \
        slurm-railway -c "$WRAPPED_CMD $CMD"
fi
