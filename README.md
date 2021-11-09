## Exoscale Wescale Demo

The slides are in `demo/wescale.pdf`

### Terraform

Add your Exoscale credentials in "main.tf" and run `terraform apply`. It will deploy the infrasteucture described in the slides.

### Ansible/Go app

The Ansible playbook will deploy a simple application (a Golang binary) managed by systemd on an instance pool. This application will save in the Postgresql database created with Terraform the process hostname and the timestamp everytime a new request is made on it.

The application will also return the hostname of the instance responding to the request (a good way to see that the load balancing is working as expected).

The application code is in `demo/go`. The Ansible playbook is currently installing the application binary by downloading it from SOS (Exoscale S3 storage).

You should configure the database access in order to make it work in the `demo/ansible/files/webapp/webapp.service` app. The `Environment=PG_URL=` line expects the URL to PostgreSQL, and `Environment=PG_PASSWORD=` the database password.

These information can be retrieved using `exo dbaas -z de-fra-1 show pg-example --uri` once the database is created.

You should then be able to launch Ansible using `ansible-playbook -i inventory/exoscale.py playbook.yaml`. Note that the dynamic inventory used use the Exoscale V1 API (which is an API faking the Cloudstack API), so the `CLOUDSTACK_KEY` and `CLOUDSTACK_SECRET` variables should be set with your Exoscale credentials. The variable `CLOUDSTACK_ENDPOINT` should also be set to https://api.exoscale.com/v1/endpoint.

