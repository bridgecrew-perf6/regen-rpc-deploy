# Regen - Public RPC Deployment
---
## Builds **_2_**  EC2 nodes behind AWS Load Balancer

##### **Requirements:** terraform, ansible, jq

Execute to run terraform/ansible.
This builds *2* AWS instances, 1 load balancer, ansible installs regen binary and starts process using state-sync.

```
./run_terraform.sh
```

Notes:   
- Update SSH key path for ansible in **./run_terraform.sh**
- If changing number of EC2 instances, update **./run_terraform.sh** to put IP's in inventory.