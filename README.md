# Slurm on Railway

Why? Why not. POC of running Slurm controller + container-local worker nodes on Railway. Only local dependencies are `railway` CLI and `docker`.

## Deployment

1. Deploy with railway template
2. Create `railway.env` file with your project info
2. Expose TCP proxy
3. Run commands: 

```bash
chmod +x client.sh
./client.sh <proxy-domain:port> <command>
```

## Client script

1. Builds a local Docker image `slurm-railway`.
2. Fetches the authentication key (created at build-time) and hostname (set by Railway at runtime) from Railway
3. Launch a background `sackd` (Slurm Auth and Cred Kiosk) daemon inside the container to handle the `auth/slurm` handshake.
4. Run given command / drop into bash

