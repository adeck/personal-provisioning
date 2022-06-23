
# ansible/monitor

> :warning: The code here is not yet production-ready.
> The monitoring host only monitors itself and the security config is incomplete.
> I am not using this code in a production context.
> You should not either.
> You have been warned.

## What is this code?

The [ansible][] playbook here (`monitor.yaml`) sets up the [Elastic stack][] (Elasticsearch, Kibana, and Metricbeat) v. >= 8.2 on a Debian 11 host.

## How do I run it?

### Prerequisites

The easiest way to satisfy all prereqs implicitly is to follow the instructions in the [terraform-infra README][].
If you've followed the steps in that guide, you can skip the rest of this section on prereqs.

This ansible playbook assumes a few things about the machine it is configuring, namely:

1. The host has internet access.
2. The host is running Debian 11.
3. The user you SSH to either is root, or has the appropriate permissions to run `sudo -i` (become root) without prompting for a password.

Aside from the above there are no assumptions in the playbook itself.

The playbook identifies the host it's targeting as `monitor`.
How ansible connects to this host is configured by your SSH config, and also by the inventory file (`inventory.yaml`) in this directory.
Assuming you make no changes to the inventory file, ansible will attempt to connect to your server with the command `ssh admin@monitor`.
If that will not work for you, see the [docs on inventory files][] and [docs on SSH config][].

### Provisioning the ELK server

After cloning the repo to your local machine and `cd`ing to the same directory as this README, [create a python virtualenv][]. Once you've created + activated the virtualenv, install `ansible` by running:

    python3 -m pip install -r requirements.txt

Before trying to actually configure the host, let's validate that you can properly access the host with your SSH + inventory settings:

    ansible -i inventory.yaml -m ping monitor

Output should look similar to:

    monitor | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false,
        "ping": "pong"
    }

Then run the following to create + encrypt the config file you will need for setup:

    mkdir -p nogit/vaults/
    export CUR_ENV=devel
    export VAULT_PATH="nogit/vaults/${CUR_ENV}-vault.yaml"
    # the following command will create a YAML file with encrypted contents
    # for details on what it's doing, see: https://docs.ansible.com/ansible/latest/user_guide/vault.html
    # it will prompt you for a password it'll use to encrypt the contents of this file
    # strongly recommend using a password manager to generate + store the password you use to encrypt this file
    # you will need this password soon
    ansible-vault create --vault-id "${CUR_ENV}@prompt" "${VAULT_PATH}"

That last step will drop you into an editor.
Enter the following YAML then save and close the editor:

    elasticsearch:
        users:
            # This will be the password to the `elastic` user, which is basically the admin user for elasticsearch.
            # This user has all permissions on elasticsearch.
            # Change to whatever password / passphrase you want, strongly recommend using a password manager or openssl to generate.
            # You will need to enter this password into your browser later.
            elastic: I am a bad password.

Nearly there! All that's left now is to run the playbook with this command:

    # you will need to unlock the vault using the password you entered on the commandline when you created the vault
    ansible-playbook -i inventory.yaml --vault-id $CUR_ENV@prompt monitor.yaml

Woo! Assuming everything ran properly, you should be able to log into your new host through your browser!
Run:

    # if the host you're configuring is not named `monitor`, change the name here
    # this will create a port forwarder, that will forward any packets from your localhost port 7000 to port 5601 on the monitor host
    ssh -N -L :7000:localhost:5601 monitor

Now navigate to http://localhost:7000 (you may need to change browser settings to allow this).
Log in using the username `elastic` and the password you put in the vault YAML file above.
A good dashboard to look at would be the `[Metricbeat System] Host overview ECS` dashboard, so search for that by name in the search bar at the top of the page.
It may take a couple of minutes for the dashboard to be properly populated with data.

[ansible]: https://docs.ansible.com/ansible/latest/getting_started/index.html
[Elastic stack]: https://www.elastic.co/
[terraform-infra README]: https://github.com/adeck/terraform-infra/
[docs on inventory files]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[docs on SSH config]: https://linux.die.net/man/5/ssh_config
[create a python virtualenv]: https://docs.python.org/3/tutorial/venv.html

