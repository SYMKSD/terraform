provider "aws" {
  region = "ap-south-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "tuto"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "iam_ec2_rl" {
  name = "iam-ec2-rl"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  path = "/"
  tags = {
    Name = "iam-ec2-rl"
    Organization = "sloopstash"
  }
}
resource "aws_iam_role_policy_attachment" "iam_ec2_rl_plcy_1" {
  depends_on = [aws_iam_role.iam_ec2_rl]
  role = aws_iam_role.iam_ec2_rl.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "iam_ec2_rl_plcy_2" {
  depends_on = [aws_iam_role.iam_ec2_rl]
  role = aws_iam_role.iam_ec2_rl.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "iam_ec2_rl_plcy_3" {
  depends_on = [aws_iam_role.iam_ec2_rl]
  role = aws_iam_role.iam_ec2_rl.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_instance_profile" "iam_ec2_rl_inst_pf" {
  depends_on = [aws_iam_role.iam_ec2_rl]
  role = aws_iam_role.iam_ec2_rl.name
  path = "/"
  tags = {
    Name = "iam-ec2-rl-inst-pf"
    Organization = "sloopstash"
  }
}
resource "aws_vpc" "vpc_net" {
  cidr_block = var.environment == "prd" ? "11.1.0.0/16" : "12.1.0.0/16"
  assign_generated_ipv6_cidr_block = false
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "vpc-net"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "vpc_bastion_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.1.0/24" : "12.1.1.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags = {
    Name = "vpc-bastion-sn-1"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "vpc_bastion_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.2.0/24" : "12.1.2.0/24"
  availability_zone = "${data.aws_region.current.name}b"
  tags = {
    Name = "vpc-bastion-sn-2"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "vpc_nat_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.3.0/24" : "12.1.3.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags = {
    Name = "vpc-nat-sn-1"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "vpc_nat_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.4.0/24" : "12.1.4.0/24"
  availability_zone = "${data.aws_region.current.name}b"
  tags = {
    Name = "vpc-nat-sn-2"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "vpc_loadbalancer_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.5.0/24" : "12.1.5.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags = {
    Name = "vpc-loadbalancer-sn-1"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "vpc_loadbalancer_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.6.0/24" : "12.1.6.0/24"
  availability_zone = "${data.aws_region.current.name}b"
  tags = {
    Name = "vpc-loadbalancer-sn-2"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_eip" "vpc_nat_eip" {
  network_border_group = data.aws_region.current.name
  public_ipv4_pool = "amazon"
  domain = "vpc"
  tags = {
    Name = "vpc-nat-eip"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_internet_gateway" "vpc_ig" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-ig"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_nat_gateway" "vpc_ng" {
  depends_on = [
    aws_subnet.vpc_nat_sn_2,
    aws_eip.vpc_nat_eip
  ]
  subnet_id = aws_subnet.vpc_nat_sn_2.id
  allocation_id = aws_eip.vpc_nat_eip.id
  connectivity_type = "public"
  tags = {
    Name = "vpc-ng"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_route_table" "vpc_pub_rtt" {
  depends_on = [
    aws_vpc.vpc_net,
    aws_internet_gateway.vpc_ig
  ]
  vpc_id = aws_vpc.vpc_net.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_ig.id
  }
  tags = {
    Name = "vpc-pub-rtt"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_route_table" "vpc_pvt_rtt" {
  depends_on = [
    aws_vpc.vpc_net,
    aws_nat_gateway.vpc_ng
  ]
  vpc_id = aws_vpc.vpc_net.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpc_ng.id
  }
  tags = {
    Name = "vpc-pvt-rtt"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_route_table_association" "vpc_bastion_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_bastion_sn_1,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_bastion_sn_1.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_route_table_association" "vpc_bastion_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_bastion_sn_2,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_bastion_sn_2.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_route_table_association" "vpc_nat_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_nat_sn_1,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_nat_sn_1.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_route_table_association" "vpc_nat_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_nat_sn_2,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_nat_sn_2.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_route_table_association" "vpc_loadbalancer_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_loadbalancer_sn_1,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_loadbalancer_sn_1.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_route_table_association" "vpc_loadbalancer_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_loadbalancer_sn_2,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_loadbalancer_sn_2.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_security_group" "vpc_bastion_sg" {
  depends_on = [aws_vpc.vpc_net]
  name = "vpc-bastion-sg"
  vpc_id = aws_vpc.vpc_net.id
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc-bastion-sg"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_security_group" "vpc_nat_sg" {
  depends_on = [aws_vpc.vpc_net]
  name = "vpc-nat-sg"
  vpc_id = aws_vpc.vpc_net.id
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [var.environment == "prd" ? "11.1.0.0/16" : "12.1.0.0/16"]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc-nat-sg"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_security_group" "vpc_loadbalancer_sg" {
  depends_on = [aws_vpc.vpc_net]
  name = "vpc-loadbalancer-sg"
  vpc_id = aws_vpc.vpc_net.id
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc-loadbalancer-sg"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_key_pair" "ec2_rsa_kp" {
  key_name = "ec2-rsa-kp"
  public_key = var.ssh_public_key
  tags = {
    Name = "ec2-rsa-kp"
    Environment = var.environment
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
/* Kubernetes specific AWS resources*/
resource "aws_iam_role" "iam_eks_rl" {
  name = "iam-eks-rl"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  path = "/"
  tags = {
    Name = "iam-eks-rl"
    Organization = "sloopstash"
  }
}
resource "aws_iam_role_policy_attachment" "iam_eks_rl_plcy_1" {
  depends_on = [aws_iam_role.iam_eks_rl]
  role = aws_iam_role.iam_eks_rl.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_instance_profile" "iam_eks_rl_inst_pf" {
  depends_on = [aws_iam_role.iam_eks_rl]
  role = aws_iam_role.iam_eks_rl.name
  path = "/"
  tags = {
    Name = "iam-eks-rl-inst-pf"
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "container_s2_vpc_kubernetes_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.9.0/24" : "12.1.9.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags = {
    Name = "container-s2-vpc-kubernetes-sn-1"
    Environment = var.environment
    Stack = "container-s2/kubernetes"
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_subnet" "container_s2_vpc_kubernetes_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = var.environment == "prd" ? "11.1.10.0/24" : "12.1.10.0/24"
  availability_zone = "${data.aws_region.current.name}b"
  tags = {
    Name = "container-s2-vpc-kubernetes-sn-2"
    Environment = var.environment
    Stack = "container-s2/kubernetes"
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_route_table_association" "container_s2_vpc_kubernetes_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.container_s2_vpc_kubernetes_sn_1,
    aws_route_table.vpc_pvt_rtt
  ]
  subnet_id = aws_subnet.container_s2_vpc_kubernetes_sn_1.id
  route_table_id = aws_route_table.vpc_pvt_rtt.id
}
resource "aws_route_table_association" "container_s2_vpc_kubernetes_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.container_s2_vpc_kubernetes_sn_2,
    aws_route_table.vpc_pvt_rtt
  ]
  subnet_id = aws_subnet.container_s2_vpc_kubernetes_sn_2.id
  route_table_id = aws_route_table.vpc_pvt_rtt.id
}
resource "aws_security_group" "container_s2_vpc_kubernetes_sg" {
  depends_on = [
    aws_vpc.vpc_net,
    aws_security_group.vpc_bastion_sg,
    aws_security_group.vpc_loadbalancer_sg
  ]
  name = "container-s2-vpc-kubernetes-sg"
  vpc_id = aws_vpc.vpc_net.id
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
  }
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_groups = [aws_security_group.vpc_bastion_sg.id]
  }
  ingress {
    protocol = "tcp"
    from_port = 30000
    to_port = 32767
    security_groups = [aws_security_group.vpc_loadbalancer_sg.id]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "container-s2-vpc-kubernetes-sg"
    Environment = var.environment
    Stack = "container-s2/kubernetes"
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_eks_cluster" "eks_ct" {
  depends_on = [
    aws_iam_role.iam_eks_rl,
    aws_subnet.vpc_loadbalancer_sn_1,
    aws_subnet.vpc_loadbalancer_sn_2,
    aws_subnet.container_s2_vpc_kubernetes_sn_1,
    aws_subnet.container_s2_vpc_kubernetes_sn_2,
    aws_security_group.container_s2_vpc_kubernetes_sg
  ]
  name = "eks-ct"
  role_arn = aws_iam_role.iam_eks_rl.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    subnet_ids = [
      aws_subnet.vpc_loadbalancer_sn_1.id,
      aws_subnet.vpc_loadbalancer_sn_2.id,
      aws_subnet.container_s2_vpc_kubernetes_sn_1.id,
      aws_subnet.container_s2_vpc_kubernetes_sn_2.id
    ]
    security_group_ids = [aws_security_group.container_s2_vpc_kubernetes_sg.id]
  }
  version = "1.36"
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  bootstrap_self_managed_addons = true
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = false
    }
    ip_family = "ipv4"
  }
  storage_config {
    block_storage {
      enabled = false
    }
  }
  compute_config {
    enabled = false
  }
  zonal_shift_config {
    enabled = false
  }
  tags = {
    Name = "eks-ct"
    Environment = var.environment
    Stack = "container-s2/kubernetes"
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
resource "aws_eks_node_group" "eks_gnr_ng" {
  depends_on = [
    aws_iam_role.iam_ec2_rl,
    aws_subnet.container_s2_vpc_kubernetes_sn_1,
    aws_subnet.container_s2_vpc_kubernetes_sn_2,
    aws_security_group.vpc_bastion_sg,
    aws_key_pair.ec2_rsa_kp,
    aws_eks_cluster.eks_ct
  ]
  node_group_name = "eks-gnr-ng"
  cluster_name = aws_eks_cluster.eks_ct.name
  node_role_arn = aws_iam_role.iam_ec2_rl.arn
  subnet_ids = [
    aws_subnet.container_s2_vpc_kubernetes_sn_1.id,
    aws_subnet.container_s2_vpc_kubernetes_sn_2.id
  ]
  version = "1.36"
  ami_type = "AL2023_x86_64_STANDARD"
  capacity_type = "ON_DEMAND"
  instance_types = ["t3a.small","t4g.small"]
  disk_size = 20
  force_update_version = true
  remote_access {
    ec2_ssh_key = aws_key_pair.ec2_rsa_kp.id
    source_security_group_ids = [aws_security_group.vpc_bastion_sg.id]
  }
  update_config {
    max_unavailable_percentage = 30
  }
  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }
  tags = {
    Name = "eks-gnr-ng"
    Environment = var.environment
    Stack = "container-s2/kubernetes"
    Region = data.aws_region.current.name
    Organization = "sloopstash"
  }
}
 