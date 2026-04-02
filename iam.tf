data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "route53_access" {
  statement {
    sid    = "Route53ZoneAccess"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${var.route53_zone_id}",
    ]
  }

  statement {
    sid    = "Route53ChangeStatus"
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = [
      "arn:aws:route53:::change/*",
    ]
  }
}

resource "aws_iam_role" "instance" {
  name               = "FunMechanicsSiteInstance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "route53_access" {
  name   = "FunMechanicsRoute53Access"
  policy = data.aws_iam_policy_document.route53_access.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "route53_access" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.route53_access.arn
}

resource "aws_iam_instance_profile" "instance" {
  name = "FunMechanicsSiteInstanceProfile"
  role = aws_iam_role.instance.name
}

