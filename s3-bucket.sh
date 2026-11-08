#!/bin/bash

set -e  # para se qualquer comando falhar

BUCKET_NAME="carldev-lab-tfstate"
TABLE_NAME="carldev-lab-tflock"
REGION="us-east-2"

echo "Criando bucket S3..."
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

echo "Habilitando versionamento..."
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

echo "Habilitando criptografia..."
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

echo "Bloqueando acesso público..."
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Criando tabela DynamoDB para lock..."
aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo "✅ Pronto! Backend criado:"
echo "   Bucket:   $BUCKET_NAME"
echo "   DynamoDB: $TABLE_NAME"
echo "   Região:   $REGION"