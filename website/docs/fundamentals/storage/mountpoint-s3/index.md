---
title: Mountpoint for Amazon S3
sidebar_position: 30
sidebar_custom_props: { "module": true }
description: "Serverless object storage for workloads on Amazon Elastic Kubernetes Service with Amazon S3."
---

::required-time

:::tip Before you start
Prepare your environment for this section:

```bash timeout=1800 wait=30
$ prepare-environment fundamentals/storage/s3
```

This will make the following changes to your lab environment:

- Create an IAM role for the Mountpoint for Amazon S3 CSI driver
- Create an Amazon S3 bucket for use in the workshop

You can view the Terraform that applies these changes [here](https://github.com/VAR::MANIFESTS_OWNER/VAR::MANIFESTS_REPOSITORY/tree/VAR::MANIFESTS_REF/manifests/modules/fundamentals/storage/s3/.workshop/terraform).

:::

[Amazon Simple Storage Service](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) (Amazon S3) is an object storage service offering industry-leading scalability, data availability, security, and performance. Organizations of all sizes and industries use Amazon S3 to store and protect any amount of data for various use cases, including data lakes, websites, mobile applications, backup and restore, enterprise applications, IoT devices, and big data analytics. Amazon S3 provides comprehensive management features to optimize, organize, and configure access to your data based on your specific business, organizational, and compliance requirements.

[Mountpoint for Amazon S3](https://github.com/awslabs/mountpoint-s3) is a high-throughput file client that enables [mounting an Amazon S3 bucket as a local file system](https://aws.amazon.com/blogs/storage/the-inside-story-on-mountpoint-for-amazon-s3-a-high-performance-open-source-file-client/). With Mountpoint for Amazon S3, applications can access objects stored in Amazon S3 through standard file operations like open and read. Mountpoint for Amazon S3 transparently translates these operations into S3 object API calls, providing applications with access to the elastic storage and throughput of Amazon S3 through a familiar file interface.

In this lab, we will create an Amazon S3 bucket to store images and then mount that bucket using Mountpoint for Amazon S3 to provide persistent, shared storage for our EKS cluster.
