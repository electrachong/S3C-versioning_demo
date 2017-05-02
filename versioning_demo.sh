#!/bin/bash

S3_SERVER='--profile scality --endpoint http://localhost:8000'
BUCKET='testbucket'
KEY='testfoo'

# create bucket
# aws s3api create-bucket --bucket $BUCKET $S3_SERVER

: 'output:
{
    "Location": "/testbucket2"
}'

# put object without versioning enabled
# aws s3api put-object --bucket $BUCKET --key $KEY $S3_SERVER --body foo1

: 'output:
{
    "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\""
}'

# enable versioning on bucket
# aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Enabled $S3_SERVER

# get bucket versioning
# aws s3api get-bucket-versioning --bucket $BUCKET $S3_SERVER

: 'output:
{
    "Status": "Enabled"
}'

# put object with versioning enabled
# aws s3api put-object --bucket $BUCKET --key $KEY $S3_SERVER --body foo2

: 'sample output:
{
    "VersionId": "98510238070775999999undef1028",
    "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\""
}'

# list versions
# aws s3api list-object-versions --bucket $BUCKET $S3_SERVER
: 'sample output:
{
    "Versions": [
        {
            "LastModified": "2017-03-17T14:45:29.224Z",
            "VersionId": "98510238070775999999undef1028",
            "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
            "StorageClass": "STANDARD",
            "Key": "testfoo",
            "Owner": {
                "DisplayName": "Bart",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "IsLatest": true,
            "Size": 0
        },
        {
            "LastModified": "2017-03-17T14:17:55.622Z",
            "VersionId": "null",
            "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
            "StorageClass": "STANDARD",
            "Key": "testfoo",
            "Owner": {
                "DisplayName": "Bart",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "IsLatest": false,
            "Size": 0
        }
    ]
}'

# get null version
# aws s3api get-object --bucket $BUCKET --key $KEY --version-id '3938353036323539393535383337393939393939756e64656630' $KEY $S3_SERVER
: 'sample output:
{
    "LastModified": "Fri, 17 Mar 2017 14:17:55 GMT",
    "ContentLength": 0,
    "VersionId": "null",
    "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
    "Metadata": {}
}'

# get specific version
# VERSION_ID="3938353037383939353636333438393939393939756e64656631"
# aws s3api get-object --bucket $BUCKET --key $KEY --version-id $VERSION_ID $KEY $S3_SERVER

: 'sample output:
{
    "LastModified": "Fri, 17 Mar 2017 15:10:00 GMT",
    "ContentLength": 5,
    "VersionId": "98510236599428999999undef0",
    "ETag": "\"b5b197d823fc1db88019cc9f786469a9\"",
    "Metadata": {}
}'

# suspend versioning
# aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Suspended $S3_SERVER

# get versioning configuration
# aws s3api get-bucket-versioning --bucket $BUCKET $S3_SERVER

: 'output:
{
    "Status": "Suspended"
}'

# put object when versioning suspended
# aws s3api put-object --bucket $BUCKET --key $KEY $S3_SERVER --body foo3

: 'sample output (no version id):
{
    "ETag": "\"171d667213c103062800d03d6316a860\""
}'

# list versions
# aws s3api list-object-versions --bucket $BUCKET $S3_SERVER

# get object (master)
# aws s3api get-object --bucket $BUCKET --key $KEY $KEY $S3_SERVER
: 'sample output (also show content of testfoo):
{
    "LastModified": "Fri, 17 Mar 2017 15:16:53 GMT",
    "ContentLength": 5,
    "VersionId": "null",
    "ETag": "\"171d667213c103062800d03d6316a860\"",
    "Metadata": {}
}'

# re-enable versioning and delete object
# aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Enabled $S3_SERVER
# aws s3api delete-object --bucket $BUCKET --key $KEY $S3_SERVER
: 'sample output:
{
    "VersionId": "98510235499868999999undef2",
    "DeleteMarker": true
}'

# get object (master, should return no such key now)
# aws s3api get-object --bucket $BUCKET --key $KEY $KEY $S3_SERVER
: 'output:
An error occurred (NoSuchKey) when calling the GetObject operation: The specified key does not exist.'

# list versions (show delete marker)
# aws s3api list-object-versions --bucket $BUCKET $S3_SERVER
: 'sample output: {
    "DeleteMarkers": [
        {
            "Owner": {
                "DisplayName": "Bart",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "IsLatest": true,
            "VersionId": "98510235499868999999undef2",
            "Key": "testfoo",
            "LastModified": "2017-03-17T15:28:20.131Z"
        }
    ],
    "Versions": [
        {
            "LastModified": "2017-03-17T15:16:53.021Z",
            "VersionId": "null",
            "ETag": "\"171d667213c103062800d03d6316a860\"",
            "StorageClass": "STANDARD",
            "Key": "testfoo",
            "Owner": {
                "DisplayName": "Bart",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "IsLatest": false,
            "Size": 5
        },
        {
            "LastModified": "2017-03-17T15:10:00.570Z",
            "VersionId": "98510236599428999999undef0",
            "ETag": "\"b5b197d823fc1db88019cc9f786469a9\"",
            "StorageClass": "STANDARD",
            "Key": "testfoo",
            "Owner": {
                "DisplayName": "Bart",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "IsLatest": false,
            "Size": 5
        }
    ]
}'

# delete delete marker
# VERSION_ID=3938353037383939313634363332393939393939756e64656633
# aws s3api delete-object --bucket $BUCKET --key $KEY --version-id $VERSION_ID $S3_SERVER

: 'sample output:
{
    "VersionId": "98510235499868999999undef2",
    "DeleteMarker": true
}'

# get object (master, should return foo3 now)
# aws s3api get-object --bucket $BUCKET --key $KEY $KEY $S3_SERVER

: 'sample output:
{
    "LastModified": "Fri, 17 Mar 2017 15:16:53 GMT",
    "ContentLength": 5,
    "VersionId": "null",
    "ETag": "\"171d667213c103062800d03d6316a860\"",
    "Metadata": {}
}'

# delete specific version
# VERSION_ID=3938353037383939363139373138393939393939756e64656630
# aws s3api delete-object --bucket $BUCKET --key $KEY --version-id $VERSION_ID $S3_SERVER

: 'sample output:
{
    "VersionId": "98510236599428999999undef0",
}'

# list versions
# aws s3api list-object-versions --bucket $BUCKET $S3_SERVER
: 'sample output:
{
    "Versions": [
        {
            "LastModified": "2017-03-17T15:16:53.021Z",
            "VersionId": "null",
            "ETag": "\"171d667213c103062800d03d6316a860\"",
            "StorageClass": "STANDARD",
            "Key": "testfoo",
            "Owner": {
                "DisplayName": "Bart",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "IsLatest": true,
            "Size": 5
        }
    ]
}'

# delete null version
# aws s3api delete-object --bucket $BUCKET --key $KEY --version-id null $S3_SERVER
: 'output:
{
    "VersionId": "null"
}'

# list versions
# aws s3api list-object-versions --bucket $BUCKET $S3_SERVER

# put object a couple times
# aws s3api put-object --bucket $BUCKET --key $KEY $S3_SERVER

# get object acl (master version)
# aws s3api get-object-acl --bucket $BUCKET --key $KEY $S3_SERVER
: 'sample output:
{
    "Owner": {
        "DisplayName": "Bart",
        "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
    },
    "Grants": [
        {
            "Grantee": {
                "Type": "CanonicalUser",
                "DisplayName": "Bart",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "Permission": "FULL_CONTROL"
        }
    ]
}'

# put object acl (master version)
# aws s3api put-object-acl --bucket $BUCKET --key $KEY --acl public-read-write $S3_SERVER

# get object acl (master version)
# VERSION_ID=null
# aws s3api get-object-acl --bucket $BUCKET --key $KEY --version-id $VERSION_ID $S3_SERVER

# put object acl (specific version)
# VERSION_ID=null
# aws s3api put-object-acl --bucket $BUCKET --key $KEY --version-id $VERSION_ID --acl public-read $S3_SERVER
# aws s3api get-object-acl --bucket $BUCKET --key $KEY --version-id $VERSION_ID $S3_SERVER
