
# ansible/monitor

> :warning: The code here is not yet production-ready.
> While it does provision the Elastic stack, the monitoring host currently only monitors itself, and while it does functionally work I haven't locked down the security config.
> I am not (yet) using this code in a prod context.
> You should not either.
> You have been warned.

## What is this code?

The playbook here (`monitor.yaml`) sets up the Elastic stack (Elasticsearch, Kibana, and Metricbeat) v. >= 8.2 on a Debian 11 host.

## How do I run it?

### Prerequisites

For the ansible playbook to run correctly, you will need a Debian 11 host.
You will need to be able to SSH to that host by running the command `ssh admin@monitor`.
You can get around some of this by changing your SSH config and / or altering the `inventory.yaml` file in this directory.

The easiest way to satisfy those requirements implicitly is to follow the instructions in the [terraform-infra README][].
However, aside from the `inventory.yaml`, no other part of the code makes any assumptions except that:

1. The host has internet access.
2. The host is running Debian 11.
3. The user you SSH to either is root, or has the appropriate permissions to run `sudo -i` (become root) without prompting for a password.

### How-To

First [create a python virtualenv][] and install [`ansible`][] into that virtualenv by entering this directory and running:

    python3 -m pip install -r requirements.txt

Then run the following:

    mkdir -p nogit/keys/
    export CUR_ENV=devel
    export VAULT_PATH="nogit/vaults/${CUR_ENV}-vault.yaml"
    # the following command will create a YAML file with encrypted contents
    # for details on what it's doing, see: https://docs.ansible.com/ansible/latest/user_guide/vault.html
    # it will prompt you for a password it'll use to encrypt the contents of this file
    # strongly recommend using a password manager to generate + store the password you use to encrypt this file
    # you will need this password soon
    ansible-vault create --vault-id "${CUR_ENV}@prompt" "${VAULT_PATH}"

On that last step, put the following into the file you're creating then save and close the editor:

    elasticsearch:
        users:
            # This will be the password to the `elastic` user, which is basically the admin user for elasticsearch.
            # This user has all permissions on elasticsearch.
            # Change to whatever password / passphrase you want, strongly recommend using a password manager or openssl to generate.
            # You will need to enter this password into your browser later.
            elastic: I am a bad password.

Nearly there! All that's left now is to run the playbook by running:

    # you will need to unlock the vault using the password you entered on the commandline when you created the vault
    ansible-playbook -i inventory.yaml --vault-id $CUR_ENV@prompt monitor.yaml

Woo! Assuming everything ran properly, you should be able to log into your new host through your browser!
Run:

    # if the host you're configuring is not named `monitor`, change the name here
    # this will create a port forwarder, that will forward any packets from your localhost port 7000 to port 5601 on the monitor host
    ssh -N -L :7000:localhost:5601 monitor

Now navigate to http://localhost:7000 (you may need to change browser settings to allow this).
Log in using the username `elastic` and the password you put in the vault YAML file above.
A good dashboard to look at would be the `[Metricbeat System] Host overview ECS` dashboard.
It may take a couple of minutes for the dashboard to be properly populated with data.

[terraform-infra README]: https://github.com/adeck/terraform-infra/
[create a python virtualenv]: https://docs.python.org/3/tutorial/venv.html
[`ansible`]: https://www.ansible.com/

