resource "aws_security_group" "cluster" {
  name        = "${var.name}-cluster"
  description = "EKS control plane communication"
  vpc_id      = var.vpc_id
  ingress {
    description = "Kubernetes API"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.cluster_api_allowed_cidrs
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-cluster-sg" })
}
resource "aws_security_group" "nodes" {
  name        = "${var.name}-nodes"
  description = "EKS managed node communication"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Control plane to kubelet"
    protocol        = "tcp"
    from_port       = 10250
    to_port         = 10250
    security_groups = [aws_security_group.cluster.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-nodes-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_nodes" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "-1"
  description                  = "Node-to-node communication"
}
