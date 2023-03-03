data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  # Used to find this account's permission boundary policy
  ##account_id = data.aws_caller_identity.current.account.id

  # Append one of these to the front of names and other properties that must be
  # unique accross all stacks in an account, such as DNS names
  # Example = name = "${local.slug_hyphen}test-securitygroup"

  ##  slug_hyphen = (var.slug == "" ? "" : "${lower(var.slug)}-")
  ##  slug_space  = (var.slug == "" ? "" : "${var.slug} ")
}
