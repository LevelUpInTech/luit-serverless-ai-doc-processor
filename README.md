# LUIT Academy — Serverless AI Document Processor

> **Monday Challenge Starter Kit**
> Deploy a serverless AI pipeline on AWS using Lambda + S3 + Amazon Bedrock + Terraform.

---

## What This Builds

```
[You upload a .txt or .pdf]
        ↓
   [S3 Input Bucket]  ──triggers──>  [AWS Lambda (Python)]
                                             ↓
                                  [Amazon Bedrock - Claude]
                                             ↓
                              [S3 Output Bucket → AI Summary]
```

Everything provisioned as Infrastructure as Code with Terraform.

---

## Prerequisites

- AWS Account with Bedrock model access enabled
- Terraform >= 1.5.0
- AWS CLI configured (aws configure)

---

## Deploy in 5 Steps

```bash
# 1. Clone the repo
git clone https://github.com/LevelUpInTech/luit-serverless-ai-doc-processor.git
cd luit-serverless-ai-doc-processor

# 2. Initialize Terraform
terraform init

# 3. Review what will be created
terraform plan

# 4. Deploy
terraform apply

# 5. Upload a test document
aws s3 cp test.txt s3://luit-ai-doc-input-dev/
```

---

## Customizing Bucket Names

Bucket names must be globally unique. Update variables.tf or pass at apply time:

```bash
terraform apply -var="input_bucket_name=YOUR-UNIQUE-INPUT-NAME" -var="output_bucket_name=YOUR-UNIQUE-OUTPUT-NAME"
```

---

## Verify It Worked

```bash
# Check CloudWatch logs (screenshot these for your proof!)
aws logs tail /aws/lambda/luit-doc-processor --follow

# Read your AI summary from the output bucket
aws s3 cp s3://luit-ai-doc-output-dev/summaries/test_summary.txt -
```

---

## Post Your Proof

1. Screenshot your CloudWatch logs showing a successful invocation
2. Drop it in the LUIT Academy community: https://skool.com/luit-academy

---

## Clean Up

```bash
terraform destroy
```

---

## Resources

- LUIT Academy Classroom: https://skool.com/luit-academy
- Amazon Bedrock Docs: https://docs.aws.amazon.com/bedrock/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest

---

*Built for the LUIT Academy community. Let's get it. 💪*
