# personal-provisioning

A repo for provisioning my cloud infrastructure.

Short version:
- terraform sets up everything but what's actually on the boxen (VPC, SGs, subnets, EIPs, forwarding tables, etc.)
- ansible sets up salt infrastructure (I'm kind of... over ansible for the foreseeable future outside the context of bootstrapping salt. :P )
- salt configures the boxen (files, installed packages, running services, etc.)

Haven't done much with packer yet.
Don't really see a huge need at this point.
With the salt highstate apply the limiting factor of speed in box setup is just the time it takes to set up the most complicated environment, and none of the environments I'm describing are complicated yet.

So far I've got two boxen, an SSH gateway and a salt master. DNS within the subnet diverges from DNS outside the subnet.
The terraform isn't actually all that complicated. Just messy. Needs a bit of cleaning. But I'm putting that off to work more on the salt, b/c the terraform is good enough for now.

