terraform init -json >> data.md
terraform validate -json >> data.md
terraform plan -json >> data.md
terraform apply -auto-approve -json >> data.md
terraform destroy -auto-approve -json >> data.md