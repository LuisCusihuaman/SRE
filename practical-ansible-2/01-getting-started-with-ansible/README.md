# Step 0 - Generate ssh key 
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible -C "ansible-demo"
```
# Step 1 - Setup servers target ansible inventory 
```
terraform init

terraform apply

chmod 400 ~/.ssh/ansible.pub
```
# Step 2 - Verifying the Ansible installation

```
ansible --private-key ~/.ssh/ansible -u ubuntu frontends -i hosts -m ping
```

# Set 3 - Use

Create a new directory on all hosts in the frontends inventory group, and create it with specific ownership and permissions:
```
ansible --private-key ~/.ssh/ansible -u ubuntu frontends -i hosts -m file -a "dest=/home/ubuntu/new mode=777 owner=ubuntu group=ubuntu state=directory"
```

Delete a specific directory from all hosts in the frontends group with the following command:
```
ansible --private-key ~/.ssh/ansible -u ubuntu frontends -i hosts -m file -a "dest=/home/ubuntu/new mode=777 owner=ubuntu group=ubuntu state=directory"
```

Install the apache2 package with apt if it is not already presentif it is present, do not update it. Again, this applies to all hosts in the frontends inventory group:
```
ansible --private-key ~/.ssh/ansible -u ubuntu -b frontends -i hosts -m apt -a "name=apache2 state=present"
```