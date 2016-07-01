# Terraubecorestack: Terraform + Kubernetes on CoreOS on OpenStack

This is a Terraform codification of the kuberenetes setup here: <https://coreos.com/kubernetes/docs/latest/getting-started.html>

Special Sauce: uses consul for holding tf rendered files headed for the OS. Still deciding if that was a good idea or not.

## TODOS

- remove hardcoded deps on my environment
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

master

Jul 01 07:45:41 coreos0 kubelet-wrapper[1355]: E0701 07:45:41.953248 1355 kubelet.go:1131] Unable to construct api.Node object for kubelet: failed to get external ID from cloud provider: Failed to find object

Jul 01 07:45:42 coreos0 etcd2[1016]: got unexpected response error (etcdserver: request timed out)

Jul 01 07:45:39 coreos0 fleetd[1024]: ERROR engine.go:217: Engine leadership lost, renewal failed: context deadline exceeded

Jul 01 07:44:55 coreos0 kernel: SELinux: mount invalid. Same superblock, different security settings for (dev mqueue, type mqueue)
