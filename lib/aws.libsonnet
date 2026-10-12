// aws.libsonnet
{
  title: 'AWS Provider Library',
  version: '1.0',
  name: 'AWS',
  decode: {
    account: 'account',
    connectivity: 'direct_connect',
    compute: 'ec2',
    database: 'rds',
    dns: 'route53',
    gateway: 'gateway',
    firewall: 'security_group',
    kubernetes: 'eks',
    load_balancer: 'elb',
    network: 'vpc',
    record: 'record',
    region: 'region',
    resolver: 'resolver',
    router: 'transit_gateway',
    storage: 'storage',
    subscription: 'management_account',
    subnet: 'subnet',
    key_management: 'vault',
    vpn: 'vpn',
    wallet: 'wallet',
    zone: 'hosted_zone',
  },
  portfolio: [
    "container",
    "connectivity",
    "compute",
    "firewall",
    "database",
    "dns",
    "storage",
    "iam",
    "key_management",
    "kubernetes",
    "load_balancer",
    "network",
    "vpn"
  ],
  roles: {
    "compute-administrator": {
      "service": "compute",
      "component": {
          "instance": "ec2",
          "fleet": "autoscaling",
          "access": "ec2instanceconnect",
          "pipeline": "imagebuilder",
      },
      "permissions": [
        "ec2:Describe*",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances",
        "ec2:ModifyInstanceAttribute",
        "ec2:CreateImage",
        "ec2:DeregisterImage",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:AttachNetworkInterface",
        "ec2:DetachNetworkInterface",
        "autoscaling:*",
        "ec2-instance-connect:*",
        "imagebuilder:*"
      ],
      "description": "Manage compute instances, images, autoscaling and instance connectivity. Restrict iam:PassRole separately to approved compute service roles."
    },
    "storage-administrator": {
      "service": "storage",
      "component": {
          "object": "s3",
          "block": "ebs",
          "file": "elasticfilesystem",
          "backup": "backup",
      },
      "permissions": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation",
        "s3:GetBucketVersioning",
        "s3:GetBucketEncryption",
        "s3:GetBucketPolicy",
        "s3:GetBucketTagging",
        "s3:PutBucketVersioning",
        "s3:PutBucketEncryption",
        "s3:PutBucketTagging",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "ec2:DescribeVolumes",
        "ec2:CreateVolume",
        "ec2:ModifyVolume",
        "ec2:DeleteVolume",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "elasticfilesystem:*",
        "backup:*"
      ],
      "description": "Full operational storage administration. Protect bucket policy changes and KMS administration with separate controls where required."
    },
    "network-administrator": {
      "service": "network",
      "component": [
        "ec2",
        "elasticloadbalancing",
        "route53",
        "cloudwatch"
      ],
      "permissions": [
        "ec2:Describe*",
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:ModifyVpcAttribute",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:ModifySubnetAttribute",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:ReplaceRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:CreateInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:CreateNetworkAcl",
        "ec2:DeleteNetworkAcl",
        "ec2:*NetworkAcl*",
        "ec2:CreateVpcEndpoint",
        "ec2:ModifyVpcEndpoint",
        "ec2:DeleteVpcEndpoints",
        "elasticloadbalancing:*",
        "route53:*"
      ],
      "description": "Core VPC and L4/L7 network administration. Consider moving DNS, firewall, VPN and Direct Connect to their dedicated roles."
    },
    "database-administrator": {
      "service": "database",
      "component": {
          "RDBMS": "rds",
          "Serverless": "rds-data",
          "NoSQL": "dynamodb",
          "Memcached": "elasticache",
      },
      "permissions": [
        "rds:*",
        "rds-data:*",
        "dynamodb:*",
        "elasticache:*"
      ],
      "description": "Operational administration of database services. Exclude IAM, KMS key administration and account-level controls."
    },
    "container-administrator": {
      "service": "container",
      "component": [
        "ecs",
        "ecr"
      ],
      "permissions": [
        "ecs:*",
        "ecr:*"
      ],
      "description": "ECS cluster/service/task and container registry administration. Restrict iam:PassRole to ECS task/execution roles."
    },
    "kubernetes-administrator": {
      "service": "kubernetes",
      "component": {
          "controlplane": "eks",
          "dataplane": "eks-auth",
      },
      "permissions": [
        "eks:*",
        "eks-auth:AssumeRoleForPodIdentity"
      ],
      "description": "EKS control-plane and cluster administration. Kubernetes RBAC remains separate from AWS IAM permissions."
    },
    "load_balancer-administrator": {
      "service": "loadbalancer",
      "component": {
          "provider_managed": "elasticloadbalancing",
          "self_managed": "ec2",
      },
      "permissions": [
        "elasticloadbalancing:*",
        "ec2:Describe*",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ],
      "description": "Dedicated ELB administration with only the EC2 permissions normally needed for associated networking and security groups."
    },
    "dns-administrator": {
      "service": "dns",
      "component": {
        "server": "route53",
        "resolver":"route53resolver"
      },
      "permissions": [
        "route53:*",
        "route53resolver:*"
      ],
      "description": "Route 53 public/private DNS and Resolver administration. DNSSEC/KMS operations should be separately governed if required."
    },
    "iam-administrator": {
      "service": "iam",
      "component": [
        "iam",
        "sts"
      ],
      "permissions": [
        "iam:*",
        "sts:GetCallerIdentity"
      ],
      "description": "Highly privileged role. In a regulated environment use JIT elevation, MFA, approval and strong CloudTrail monitoring. Do not grant Organizations or billing permissions by default."
    },
    "firewall-administrator": {
      "service": "firewall",
      "component": [
        "network-firewall",
        "ec2"
      ],
      "permissions": [
        "network-firewall:*",
        "ec2:Describe*",
        "ec2:CreateVpcEndpoint",
        "ec2:ModifyVpcEndpoint",
        "ec2:DeleteVpcEndpoints"
      ],
      "description": "AWS Network Firewall administration. Resource/tag conditions should normally restrict this role to designated firewall resources."
    },
    "vpn-administrator": {
      "service": "vpn",
      "component": {
        "gateway": "ec2"
      },
      "permissions": [
        "ec2:Describe*",
        "ec2:CreateCustomerGateway",
        "ec2:DeleteCustomerGateway",
        "ec2:CreateVpnConnection",
        "ec2:DeleteVpnConnection",
        "ec2:ModifyVpnConnection",
        "ec2:CreateVpnGateway",
        "ec2:DeleteVpnGateway",
        "ec2:AttachVpnGateway",
        "ec2:DetachVpnGateway",
        "ec2:CreateVpnConnectionRoute",
        "ec2:DeleteVpnConnectionRoute",
        "ec2:CreateClientVpnEndpoint",
        "ec2:DeleteClientVpnEndpoint",
        "ec2:ModifyClientVpnEndpoint",
        "ec2:CreateClientVpnRoute",
        "ec2:DeleteClientVpnRoute",
        "ec2:AuthorizeClientVpnIngress",
        "ec2:RevokeClientVpnIngress",
        "ec2:AssociateClientVpnTargetNetwork",
        "ec2:DisassociateClientVpnTargetNetwork",
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ],
      "description": "Site-to-site and Client VPN operations. Certificates, private CA and IAM identity administration remain outside this role."
    },
    "connectivity-administrator": {
      "service": "connectivity",
      "component": {
          "cross_connect": "directconnect",
          "tunnel": "ec2",
      },
      "permissions": [
        "directconnect:*",
        "ec2:Describe*",
        "ec2:CreateTransitGateway",
        "ec2:DeleteTransitGateway",
        "ec2:ModifyTransitGateway",
        "ec2:CreateTransitGatewayRouteTable",
        "ec2:DeleteTransitGatewayRouteTable",
        "ec2:CreateTransitGatewayRoute",
        "ec2:ReplaceTransitGatewayRoute",
        "ec2:DeleteTransitGatewayRoute",
        "ec2:AssociateTransitGatewayRouteTable",
        "ec2:DisassociateTransitGatewayRouteTable",
        "ec2:CreateTransitGatewayVpcAttachment",
        "ec2:DeleteTransitGatewayVpcAttachment",
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ],
      "description": "Direct Connect and Transit Gateway connectivity. Provider/partner-side provisioning is outside AWS IAM."
    },
    "vault-administrator": {
      "service": "vault",
      "component": {
        "kms": "kms"
      },
      "permissions": [
        "kms:Describe*",
        "kms:Get*",
        "kms:List*",
        "kms:CreateKey",
        "kms:EnableKey",
        "kms:DisableKey",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:RotateKeyOnDemand",
        "kms:EnableKeyRotation",
        "kms:DisableKeyRotation",
        "kms:GetKeyRotationStatus",
        "kms:CreateAlias",
        "kms:DeleteAlias",
        "kms:UpdateAlias",
        "kms:ImportKeyMaterial",
        "kms:DeleteImportedKeyMaterial",
        "kms:TagResource",
        "kms:UntagResource",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:CreateSecret",
        "secretsmanager:UpdateSecret",
        "secretsmanager:DeleteSecret",
        "secretsmanager:RestoreSecret",
        "secretsmanager:RotateSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UntagResource"
      ],
      "description": "Full administrative lifecycle management for cryptographic keys, aliases, key rotation, and secret vaults. Data payload encryption/decryption operations (kms:Decrypt, secretsmanager:GetSecretValue) remain restricted or scoped strictly outside this role."
    },
    "auditor": {
      "service": "audit",
      "component": {
        "security": "iam"
      },
      "permissions": [
        "iam:GenerateCredentialReport",
        "iam:GenerateServiceLastAccessedDetails",
        "iam:Get*",
        "iam:List*",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetEventSelectors",
        "cloudtrail:GetInsightSelectors",
        "cloudtrail:GetTrailStatus",
        "cloudtrail:ListTags",
        "cloudtrail:ListTrails",
        "cloudtrail:LookupEvents",
        "config:DeliverConfigSnapshot",
        "config:Describe*",
        "config:Get*",
        "config:ListDiscoveredResources",
        "kms:Describe*",
        "kms:Get*",
        "kms:GetKeyPolicy",
        "kms:GetKeyRotationStatus",
        "kms:List*",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:ListSecrets",
        "ec2:Describe*"
      ],
      "description": "Read-only security, compliance, and auditing role. Allows inspecting infrastructure configurations, key policies, IAM roles, and trail event logs without access to secret payloads, key operations, or resource modification."
    },
  },

  // Retrieve deduplicated permissions by service name
  getAdminPermissions(serviceName)::
    local matchingPermissions = [
      perm
      for roleKey in std.objectFields(self.roles)
      if std.get(self.roles[roleKey], 'service') == serviceName
      for perm in std.get(self.roles[roleKey], 'permissions', default=[])
    ];
    std.set(matchingPermissions),
}
