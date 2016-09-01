# terrakube a.k.a. Terraform + Kubernetes + CoreOS on OpenStack

This is a Terraform codification of the Kubernetes setup here <https://coreos.com/kubernetes/docs/latest/getting-started.html>

Works as follows
- Terraform renders config files, keys, and scripts to consul
- The OpenStack VM's are started with the generated cloud-inits
- Cloud-init pulls all the relevant node config from consul
- Cloud-init starts the basic services (etcd, flannel, docker) needed for kubernetes
- Cloud-init starts kubelet-wrapper which completes the kubernetes setup

## Preliminary Setup
The following tools are required

1. OpenStack - distro & Release shouldn't matter much
  - requires CoreOS images in glance.  Use scripts/update-coreos.sh to upload
  - requires existing keypair
  - optional cinder for automatic Kubernetes pvc allocation
  - optional neutron lbaasv2 for Kubernetes service exposing
2. [terraform v0.6.x](https://releases.hashicorp.com/terraform/) - not ported to 0.7 yet
3. [consul](https://www.consul.io/downloads.html)
4. kubectl via [Google Cloud SDK](https://cloud.google.com/sdk/downloads) or [kubernetes](https://github.com/kubernetes/kubernetes/releases)

Only tested on Linux but should run fine on a Mac too.

## Deploy

1. Edit variables.tf. All configuration is in here.
2. Run `terrform apply`
3. Wait for terrform run to complete. Entire build time is around 6 minutes on a all-in-one OpenStack instance running on an Intel NUC.
4. Done.  kubectl should be properly configured for your cluster. Confirm with
```
% kubectl cluster-info    
Kubernetes master is running at https://10.3.0.82

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

## Troubleshooting

Network issues are most common, might need changes based on your setup.

If the node create process seems like its taking an extremely long time you can ssh into any of the nodes
```
ssh core@<ip>
```
then use journalctl to see what failed.

## TODOS

- don't reference OpenStack key-pair, generate
- update Terraform version
- add post deploy tests to confirm cluster is functioning
  - network connectivity
  - etcd cluster
  - fleet???
  - flannel
  - kubernetes conformance test

- validate pv / pvc cinder intergration
- validate ingress
- validate openstack lbaas service balancer config
- sort out template files better
- add extras: dns, dashboard, healthz, registry...
- add calico
