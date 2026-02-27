# Slurm on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/slurm-on-railway)

Why? Why not. POC of running Slurm controller + container-local worker nodes on Railway. Only local dependencies are `railway` CLI and `docker`.

## Deployment

1. Deploy with railway template - be patient, the build takes about 10 minutes but subsequent deployments will be faster.
2. Create `railway.env` file with your project info:

```bash
# After deploying the template, you can get these from the URL:
https://railway.com/project/$PROJECT_ID/service/$SERVICE_ID?environmentId=$ENVIRONMENT_ID

export RAILWAY_PROJECT_ID=xxx
export RAILWAY_ENVIRONMENT_ID=xxx
export RAILWAY_SERVICE_ID=xxx
```

3. From the `Settings` tab of your project, get your public domain and port - e.g. `interchange.proxy.rlwy.net:59019`
4. Auth your Railway CLI with `railway login`
5. Run commands using the `client.sh` wrapper:

```bash
chmod +x client.sh
./client.sh <proxy-domain:port> <command>

# example
./client.sh interchange.proxy.rlwy.net:59019 scontrol ping -vvvv
Using Project: xxx
Using Environment: xxx
Using Service: xxx
--- Building Local Slurm Image ---
sha256:639351c1520234413d42a3df8b0230e3a04e317af4a1e305bbc35e775e750759
--- Syncing with Railway ---
Warning: Received unknown message type: stand_by
Remote hostname detected: 8f524205061f
Warning: Received unknown message type: stand_by
--- Launching Client Container ---
scontrol: debug2: _sack_connect: connected to /run/slurm/sack.socket
Slurmctld(primary) at 8f524205061f is UP
```

6. Or, ssh to the container and run a local job:

```bash
source railway.env && railway ssh --project=$RAILWAY_PROJECT_ID --environment=$RAILWAY_ENVIRONMENT_ID --service=$RAILWAY_SERVICE_ID
root@54ccd73f040a:/usr/bin/sbin# srun -v date
srun: defined options
srun: -------------------- --------------------
srun: verbose             : 1
srun: -------------------- --------------------
srun: end of defined options
srun: Nodes 54ccd73f040a are ready for job
srun: jobid 6: nodes(1):`54ccd73f040a', cpu counts: 1(x1)
srun: CpuBindType=(null type)
srun: launching StepId=6.0 on host 54ccd73f040a, 1 tasks: 0
srun: topology/default: init: topology Default plugin loaded
srun: Node 54ccd73f040a, 1 tasks started
srun: Received task exit notification for 1 task of StepId=6.0 (status=0x0000).
srun: 54ccd73f040a: task 0: Completed
Fri Feb 27 11:05:13 UTC 2026
```

## Client script

1. Builds a local Docker image `slurm-railway`.
2. Fetches the authentication key (created at build-time) and hostname (set by Railway at runtime) from Railway
3. Launch a background `sackd` (Slurm Auth and Cred Kiosk) daemon inside the container to handle the `auth/slurm` handshake.
4. Run given command / drop into bash

