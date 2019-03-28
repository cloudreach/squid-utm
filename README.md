# Bringing Squid Proxy into the 21st century with AWS Fargate

## Overview

When talking about building and deploying applications in the AWS ecosystem, one topic that comes up without fail is how to securely manage outbound internet traffic from private subnets.

How can you operate a controlled environment that prevents data exfiltration or possible data leaks with a minimum amount of management overhead?

There are commercial tools available such as [NextGen Firewall](https://en.wikipedia.org/wiki/Next-generation_firewall) or [Web Proxy](https://en.wikipedia.org/wiki/Proxy_server) that can filter/block outbound web traffic but these tools require a license as well as ongoing maintenance of the software and the related AWS EC2 infrastructure.

AWS has published an excellent article on [How to Add DNS Filtering to Your NAT Instance with Squid](https://aws.amazon.com/blogs/security/how-to-add-dns-filtering-to-your-nat-instance-with-squid/), that covers the reasons for choosing a Squid-based solution to solve this problem.

Inspired by this solution, I want to take the architecture and apply modern AWS technologies like AWS Fargate and the Network Load Balancer to bring the solution into the cloud-native realm.

[Squid](http://www.squid-cache.org/) is chosen as open-source software to whitelist and blacklist URL, and combined with [Linux Alpine](https://alpinelinux.org/), fits perfectly in a container environment.

## Diagram

<p align="center">
  <img src="diagram.jpeg">
</p>

## Principles

The solution is based on the following principles:

- Provides a secure internet connection to a wide AWS landscape (multi-account/ multi-region)
- No Servers to Maintain/Update/Upgrade
- Needs to support high bandwidth throughput
- Highly available solution
- Flexible cost based on usage

## Why I used these AWS services

[AWS Fargate](https://aws.amazon.com/fargate/) is a compute engine for Amazon ECS that allows you to run containers without having to manage servers or clusters. With AWS Fargate, you no longer have to provision, configure, and scale clusters of virtual machines to run containers. This removes the need to choose server types, decide when to scale your clusters or optimize cluster packing. [AWS Application Scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html) enables you to configure automatic scaling for AWS Fargate in a matter of minutes.

[AWS Network Load Balancer](https://aws.amazon.com/blogs/aws/new-network-load-balancer-effortless-scaling-to-millions-of-requests-per-second/) operates at the connection level (Layer 4), routing connections to targets - Amazon EC2 instances, microservices, and containers – within Amazon Virtual Private Cloud (Amazon VPC) based on IP protocol data. Ideal for load balancing of TCP traffic, Network Load Balancer is capable of handling millions of requests per second while maintaining ultra-low latencies.

[AWS Cloudwatch Logs](https://aws.amazon.com/cloudwatch/features/) service allows you to collect and store logs from your resources, applications, and services in near real-time. Using the [AWS ECS awslogs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html) drivers makes it possible to publish the output log of Docker without any additional tool.

### Why use AWS Network Load Balancer?

AWS Network Load Balancer offers a very flexible configuration and high-performance connection but it also introduces the ability to configure a &quot;[Service Endpoint](https://docs.aws.amazon.com/vpc/latest/userguide/endpoint-service.html)&quot;.

Using Service Endpoint enabled to publish the Squid UTM Service across multiple accounts and across multiple regions, using [VPC PrivateLink Inter-Region](https://aws.amazon.com/about-aws/whats-new/2018/10/aws-privatelink-now-supports-access-over-inter-region-vpc-peering/), in a secure way controlling the allowed/blocked traffic in a single location.



# The solution

This solution combines Infrastructure As A Code (IaaC) using [Terraform](https://www.terraform.io/) and the AWS ECS deploying a strategy to update the configuration of the Squid Farm, using a zero-downtime strategy.

This solution enabled:

- Internet access using a proxy with a controlled whitelist/blacklist
- Avoid using AWS VPC peering with complex routing simply relying on AWS Service Endpoint
- ECS provides the high-availability scheduling with the required AWS Fargate scaling based on the CPU load of the service
- No Patch/Updates will be required anymore to maintain the base OS

# Conclusion

The final solution satisfies all principles enabling the usage of Squid in a highly dynamic environment:

- AWS ECS will handle zero-downtime deployment on every configuration change and also ensuring the high-availability and load scaling process of AWS Fargate.
- AWS Network Loadbalancer will guarantee high throughput and ultra-low latency cross region and cross-account connectivity.

These services combine together will transform and modernised the URL filtering with Squid to a cloud-friendly design.


# Terraform parameters

## Input for AWS Infrastructure

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_region | AWS region | string | `` | yes |
| vpc\_id | VPC ID | string | `` | yes |
| lb\_subnets | A list of Loadbalancer subnets inside the VPC | list | `[]` | yes |
| fargate\_subnets | A list of subnets inside the VPC for Fargate | list | `[]` | yes |
| environment | Environment name | string | `dev` | no |
| app\_name | Application name | string | `utm-squid` | no |
| app\_port | Application TCP Port | string | `3128` | no |
| fargate_image | Fargate Image | string | `cloudreach/squid-utm:1.0` | no |
| desired\_count | Fargate instance count | string | `2` | no |
| max\_count | Max Fargate instance count | string | `30` | no |
| extra\_tags | Additional tags to all tagged resources | map | `{}` | no |
| internal | Loadbalancer usage internal or not | string | `false` | no |
| health\_check\_interval | Loadbalancer health check interval | string | `30` | no |
| deregistration\_delay | time of deregistering target from draining to unused | string | `5` | no |


## Input for Squid Config

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| whitelist\_aws\_region | URL filter for AWS region | string | `eu-west-1,eu-west-2,eu-central-1` | no |
| whitelist\_url | permitted URL filter | string | `www.cloudreach.com,www.google.com` | no |
| url\_block\_all | deny all other access to this proxy | string | `false` | no |
| blacklist\_url | blocked URL filter | string | `www.exploit-db.com` | no |
| allowed\_cidrs | Comma separated list of allowed CIDR ranges permitted to use the Proxy | string | `10.0.0.0/8,172.16.0.0/12,192.168.0.0/16` | no |


## Outputs

| Name | Description |
|------|-------------|
| test\_curl | `curl` command to test the proxy |
| iam\_role | Fargate execution role |
| nlb\_arn | Network Loadbalance ARN |
| nlb\_hostname | Network Loadbalance FQDN |


# Just do IT

To use the terraform code  a quick `Makefile` can help the deployment

```bash
Terraform-makefile

apply                          Have terraform do the things. This will cost money.
del                            alias of destroy
delete                         alias of destroy
destroy                        Destroy the things
fmt                            terraform format
init                           Init terraform module
lint                           Rewrites config to canonical format
plan-destroy                   Creates a destruction plan.
plan                           Show what terraform thinks it will do
up                             alias of apply
```

To create the UTM solution with terraform just run:

```bash
$ git clone https://github.com/cloudreach/squid-utm.git
$ cd squid-utm/
$ make apply
Initializing modules...
- module.vpc-utm
- module.utm

....

Apply complete! Resources: 35 added, 0 changed, 0 destroyed.

Outputs:

test_curl = curl https://www.cloudreach.com --head --proxy dev-utm-squid-cd9173b8fc90b042.elb.eu-central-1.amazonaws.com:3128
```


To delete the UTM solution with terraform just run:

```bash
$ make destroy

....

Destroy complete! Resources: 35 destroyed.

```

## How to Contribute

We encourage contribution to our projects, please see our [CONTRIBUTING](CONTRIBUTING.md) guide for details.


## License

**squid-utm** is licensed under the [Apache Software License 2.0](LICENSE).

## Thanks

Keep It Cloudy ([@CloudreachKIC](https://twitter.com/cloudreachkic))