# personal-provisioning

A repo for provisioning my cloud infrastructure.

## What does the code in here do?

It sets up a relatively secure (nowhere near perfect, but... pretty solid. Good enough) management infrastructure within a VPC that only has one externally-facing service: the SSH gateway (which only takes incoming connections from a trusted CIDR specified at provisioning time, and uses an SSH public key also provided by the user at provisioning time).

Currently the hosts created are:

- gw-infra -- the SSH gateway host
- salt-infra -- the saltmaster
- monitoring-infra -- a monitoring host with icinga and grafana installed (still WIP; I'm still not sure I actually want to use icinga for after reading enough of the documentation to see XML, apache server setup, and references to PHP)

## TL;DR version of what each tool does

- packer creates the base debian AMI all the EC2 instances are based off of
- terraform creates all the black-box infrastructure (VPC, SGs, subnets, EIPs, forwarding tables, EC2 instances, etc.), but doesn't actually connect to the VMs or try to configure them
- ansible sets up salt infrastructure (I'm kind of... over ansible for the foreseeable future outside the context of bootstrapping salt. :P )
- salt configures the boxen (files, installed packages, running services, etc.)

## How would I actually run this thing?

You'll probably want to create a python virtualenv for this, but either way...

### export your AWS connection variables

// TODO -- talk about `AWS_ACCESS_KEY` and `AWS_SECRET_KEY`

### create the base debian AMI with packer

```
cd packer
pip install -r requirements.txt
./provision.sh
```

### provision the infrastructure with terraform

First get to the right directory...
```
pushd terraform-infra/real/infra
cp terraform.tfvars.example terraform.tfvars
```
Then fill in `terraform.tfvars` with appropriate values for your environment, and run:
```
terraform get
terraform plan
terraform apply
```

Then get back to the project top level directory
```
popd
```

### install the salt-master & configure the minions

```
pushd ansible
./run.sh
```

### then run a salt.highstate to actually configure all the boxen

```
ssh -F ssh_config -L 1234:monitoring-infra:3000 gw
ssh salt-infra
sudo -i
salt '*' state.highstate
```

### and finally, connect to grafana

In your browser, navigate to `http://localhost:1234`.
You should see a login page for grafana. The username and password are both `admin`.
At the moment it doesn't have any data sources configured.

### next steps

- configuring grafana to have a randomized admin password that gets printed to the user
- setup IAM policies and roles, and grafana internals, s.t. there's grafana dashboarding for the CloudWatch basic monitoring of all these hosts
- setup meaningful internal host monitoring- icinga and / or collectd- s.t. I can determine appropriate sizing for these machines. Currently they're at `t2.micro` with whatever the default EBS storage is, but even that's probably overkill. At least for testing the config.
- improving this documentation, and putting better explanations of variables into the terraform.tfvars file


