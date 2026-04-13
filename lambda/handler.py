"""
LUIT Academy - Serverless AI Document Processor
Triggered by S3 ObjectCreated events.
Reads the uploaded document, sends it to Amazon Bedrock (Claude),
and writes the AI-generated summary to the output S3 bucket.
Challenge: Deploy this. Test it. Post your CloudWatch proof.
"""
import json, os, boto3, urllib.parse

s3_client      = boto3.client("s3")
bedrock_client = boto3.client("bedrock-runtime", region_name=os.environ.get("AWS_DEFAULT_REGION", "us-east-1"))

OUTPUT_BUCKET = os.environ["OUTPUT_BUCKET"]
BEDROCK_MODEL = os.environ.get("BEDROCK_MODEL", "anthropic.claude-3-sonnet-20240229-v1:0")
MAX_CHARS     = 40_000


def lambda_handler(event, context):
    results = []
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key    = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        print(f"[INFO] Processing s3://{bucket}/{key}")
        try:
            text    = read_document(bucket, key)
            summary = summarize_with_bedrock(text, key)
            out_key = build_output_key(key)
            write_summary(out_key, summary, key, bucket)
            print(f"[SUCCESS] Summary written to s3://{OUTPUT_BUCKET}/{out_key}")
            results.append({"key": key, "status": "success", "output_key": out_key})
        except Exception as e:
            print(f"[ERROR] Failed to process {key}: {e}")
            results.append({"key": key, "status": "error", "error": str(e)})
    return {"statusCode": 200, "body": json.dumps({"processed": len(results), "results": results})}


def read_document(bucket, key):
    response = s3_client.get_object(Bucket=bucket, Key=key)
    content  = response["Body"].read()
    try:
        text = content.decode("utf-8")
    except UnicodeDecodeError:
        text = content.decode("latin-1")
    if len(text) > MAX_CHARS:
        text = text[:MAX_CHARS] + "\n\n[Document truncated]"
    return text


def summarize_with_bedrock(text, filename):
    prompt = f"""You are a professional document analyst. Summarize the following document.

Document: {filename}
---
{text}
---

Provide:
1. A 2-3 sentence executive summary
2. Key points (bullet list, max 5)
3. Any action items or decisions identified"""

    body = json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": prompt}]
    })
    response      = bedrock_client.invoke_model(modelId=BEDROCK_MODEL, contentType="application/json", accept="application/json", body=body)
    response_body = json.loads(response["body"].read())
    return response_body["content"][0]["text"]


def build_output_key(input_key):
    parts = input_key.rsplit(".", 1)
    return f"summaries/{parts[0]}_summary.txt"


def write_summary(output_key, summary, source_key, source_bucket):
    body = f"LUIT Academy - AI Document Summary\n{'='*36}\nSource: s3://{source_bucket}/{source_key}\nModel:  {BEDROCK_MODEL}\n\n{summary}\n"
    s3_client.put_object(Bucket=OUTPUT_BUCKET, Key=output_key, Body=body.encode("utf-8"), ContentType="text/plain")
