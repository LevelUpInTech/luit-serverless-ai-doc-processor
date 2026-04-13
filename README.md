# LUIT Academy Monday Challenge
## Serverless AI Document Processor — Lambda + S3 + Bedrock + Terraform

> **This is starter code.** It is intentionally incomplete. Your job is to finish it.

---

## What You're Building

An event-driven AWS pipeline that:
1. Watches an S3 bucket for new documents
2. Triggers a Lambda function automatically on upload
3. Sends the document text to Amazon Bedrock (Claude) for AI summarization
4. Stores the AI-generated summary in a second S3 bucket

---

## Architecture

```
[Input S3 Bucket] ──(event trigger)──> [Lambda Function] ──> [Amazon Bedrock]
                                                |
                                                v
                                       [Output S3 Bucket]
```

---

## What's Already Done For You

- ✅ `provider.tf` / Terraform setup
- ✅ Both S3 buckets (`aws_s3_bucket`)
- ✅ Lambda function resource (`aws_lambda_function`)
- ✅ IAM execution role + S3 read/write policies (`iam.tf`)
- ✅ CloudWatch log group
- ✅ Lambda handler code (`lambda/handler.py`) — calls Bedrock and writes the summary

---

## What YOU Need to Complete

### Step 1 — Fill in your variable values (`variables.tf`)

Open `variables.tf` and uncomment + set your own values for:

| Variable | What to set |
|---|---|
| `input_bucket_name` | A globally unique S3 bucket name (e.g. `yourname-luit-input-2026`) |
| `output_bucket_name` | A globally unique S3 bucket name (e.g. `yourname-luit-output-2026`) |
| `lambda_function_name` | A unique Lambda function name in your account |

---

### Step 2 — Wire up the S3 → Lambda trigger (`main.tf`)

The pipeline won't fire until you add two resources at the bottom of `main.tf`:

**Resource 1:** Give S3 permission to invoke your Lambda

```hcl
resource "aws_lambda_permission" "allow_s3" {
  # Fill this in — hints are in main.tf
}
```

**Resource 2:** Tell the input bucket to trigger Lambda on object creation

```hcl
resource "aws_s3_bucket_notification" "trigger" {
  # Fill this in — hints are in main.tf
}
```

---

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

---

## Test It

1. Upload any `.txt` or `.pdf` file to your input bucket
2. Check CloudWatch Logs — you should see a successful Lambda invocation
3. Open your output bucket — find the AI-generated summary file

---

## Post Your Proof

Drop a screenshot of your CloudWatch logs showing a successful invocation in the LUIT Academy Skool community comments.

**First 3 members to post proof get a shoutout on Friday's Wins Wall.**
