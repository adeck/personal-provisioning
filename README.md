# personal-provisioning

A repo for provisioning my infrastructure.

Right now this repo is in a state of flux.
In 2017 I was using this repo to set up a salt master / minion + icinga monitoring behind an SSH bastion, and then this repo died.
In 2022 I resurrected this repo, updating terraform layouts to support the most recent version of terraform, and adding code to support deploying an ELK stack behind an SSH bastion via ansible.

## What's in here?

- `terraform-infra/` -- terraform layouts. Terraform sets up everything but what's actually on the boxen (VPC, SGs, subnets, EIPs, forwarding tables, etc.)
- `ansible/` -- ansible playbooks. In `ansible/monitor/` I use ansible to set up an ELK stack v. 8.2. In `ansible/salt-icinga` I only use ansible to install salt components on all the hosts, and then delegate further setup to salt.
- `salt-configs/` -- Salt formulae, states, and (non-sensitive) pillar data. Currently only used for the `ansible/salt-icinga` stuff.

## How do I provision the ELK stack?


First, provision the hardware by following the instructions in the [terraform-infra README][].
Then follow the instructions in the [ansible/monitor README][].

[terraform-infra README]: https://github.com/adeck/terraform-infra/
[ansible/monitor README]: /ansible/monitor/

