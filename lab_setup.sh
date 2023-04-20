

sudo yum install ansible-core
ansible-galaxy collection install community.general

# Configure gitea and repo for builds
ansible-playbook gitea_setup.yml -e @track_vars.yml -i inventory.ini



