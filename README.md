# IaC
aws infrastructure as code

### Steps
1. Provision  
   `terraform apply`

2. Run the following command to retrieve the access credentials for your cluster and configure kubectl.  
   `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
   `
3. Verify the cluster  
   `kubectl cluster-info`

### Connect to s3 from eks nodes
- AWS recommends creating the IAM role for the service account(IRSA)