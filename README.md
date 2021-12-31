# aaronzhaocr.net-iac
The repo that contains all the IaC for my own site.


## Deployment Guide

### Terraform Backend Stack
```bash
aws cloudformation deploy --region us-east-1 --template-file terraform_backend_template.yml --stack-name aaronzhaocr-net-backend --tags Environment=Prod Project=aaronzhaocr.net manage_by=aaron.zhaocr@gmail.com version=0.0.1
```
