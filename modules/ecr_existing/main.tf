data "aws_ecr_repository" "repository" {
  for_each = var.repositories
  name     = each.key
}

resource "aws_ecr_lifecycle_policy" "policy" {
  for_each   = var.repositories
  repository = data.aws_ecr_repository.repository[each.key].name
  policy     = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${each.value.keep_last_images} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = each.value.keep_last_images
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_repository_policy" "policy" {
  for_each   = var.repositories
  repository = data.aws_ecr_repository.repository[each.key].name
  policy     = var.repository_policies[each.key]
}
