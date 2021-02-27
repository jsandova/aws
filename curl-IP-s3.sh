#!/bin/bash -x

#S3 parameters
S3KEY="**********"
S3SECRET="*******" # pass these in
S3BUCKET="aofl-hd-input"
S3STORAGETYPE="STANDARD" #REDUCED_REDUNDANCY or STANDARD etc.
AWSREGION="s3-us-west-2"
SERIAL="$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')"
#SERIAL="008"

function putS3
{
  curl ifconfig.me > /tmp/OSX_$SERIAL
  path=/tmp/
  file="OSX_$SERIAL"
  aws_path="/OSX/"
  bucket="${S3BUCKET}"
  date=$(date +"%a, %d %b %Y %T %z")
  acl="x-amz-acl:authenticated-read"
  content_type="application/octet-stream"
  storage_type="x-amz-storage-class:${S3STORAGETYPE}"
  string="PUT\n\n$content_type\n$date\n$acl\n$storage_type\n/$bucket$aws_path$file"
  signature=$(echo -en "${string}" | openssl sha1 -hmac "${S3SECRET}" -binary | base64)
  curl -s -X PUT -T "$path/$file" \
    -H "Host: $bucket.${AWSREGION}.amazonaws.com" \
    -H "Date: $date" \
    -H "Content-Type: $content_type" \
    -H "$storage_type" \
    -H "$acl" \
    -H "Authorization: AWS ${S3KEY}:$signature" \
    "https://$bucket.${AWSREGION}.amazonaws.com$aws_path$file"
}

putS3
