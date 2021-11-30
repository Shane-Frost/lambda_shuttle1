# Creating IAM role so that Lambda service to assume the role and access other AWS services. 



#reminder to myself: RESOURCES = "infrastructure objects" such as EC2, server.. bucket.. permissions. Think hardware in the old server room


#this one is for setting the "role" for lambda.
#Role = IAM role that grants the function permission to access AWS services and resources. 
# below row that says "Version" apparently it is always 2012-10-17 https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_version.html

resource "aws_iam_role" "lambda_role" {
 name   = "iam_role_lambda_function"
 #I cannot find a good description online for what EOF is.. << = read input until it finds a line containing the deliminer EOF? why? 
 #and why I must use it here. is there a way to not need it?  ask Laura or Pascal?? 
 #####
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# IAM policy for logging from a lambda
resource "aws_iam_policy" "lambda_logging" {

  name         = "iam_policy_lambda_logging_function"
  path         = "/"
  description  = "IAM policy for logging from a lambda"
policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role        = aws_iam_role.lambda_role.name #why is .name at the end? 
  policy_arn  = aws_iam_policy.lambda_logging.arn
}

# Generates an archive from content, a file, or a directory of files.
#what is this here for? : https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file
#I don't understand this part either... Run terraform plan without this? Any error? 
# data "archive_file" "default" {
#   type        = "zip"
#   source_dir  = "${path.module}/files/"
#   output_path = "${path.module}/myzip/python.zip"
# }

# Create a lambda function
# In terraform ${path.module} is the current directory.

resource "aws_lambda_function" "lambdafunc" {
  filename                       = "${path.module}/myzip/python.zip"
  function_name                  = "My_Lambda_function"
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "index.lambda_handler"
  runtime                        = "python3.8"
  depends_on                     = [aws_iam_role_policy_attachment.policy_attach]
}