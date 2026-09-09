resource "aws_ecr_repository" "this" {
  for_each             = var.repository_names
  name                 = each.value
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
  tags = merge(var.tags, { Name = each.value })
}
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = var.repository_names
  repository = aws_ecr_repository.this[each.key].name
  policy     = jsonencode({ rules = [{ rulePriority = 1, description = "Retain the most recent 30 images", selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 30 }, action = { type = "expire" } }] })
}
