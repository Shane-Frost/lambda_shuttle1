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
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
#fyi, "Resource": "arn:aws:logs:*:*:*",  = "put logs anywhere"



#You can have dozens of roles, and dozens of policies. 
#Each policy can apply to a different role, or similar roles. They can be shared.
#imagine you have two roles: Lambda_role1, and Lambda_role2. 
#you also have a policy called "lambda_logging" both lambda roles, 
#can have this policy assigned to it. using the below "policy attachement"

# Policy Attachment on the role.
#This tells the role which policy applies to it 
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role        = aws_iam_role.lambda_role.name #why is .name at the end? 
  policy_arn  = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "lambda_bucket_access" {

  name         = "iam_policy_lambda_bucket_access"
  path         = "/"
  description  = "I am permissions for my bucket."
policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::talent-academy-539350506885/*"
      ]
    }
  ]
}
EOF
}
#access for the above policy.
resource "aws_iam_role_policy_attachment" "lambda_bucket_access" {
  role        = aws_iam_role.lambda_role.name #why is .name at the end? 
  policy_arn  = aws_iam_policy.lambda_bucket_access.arn
}
# Generates an archive from content, a file, or a directory of files.
#what is this here for? : https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file
#I don't understand this part either... Run terraform plan without this? Any error? 
#will generate a zip file. 
#
data "archive_file" "pet_script" {
  type        = "zip"
  source_dir  = "${path.module}/files/" #source of file
  output_path = "${path.module}/myzip/pet_info.zip" #destination of the genreated file(.zip)
}

# Create a lambda function
# In terraform ${path.module} is the current directory.

resource "aws_lambda_function" "lambdafunc" {

                                  #I am setting the filename here, to be data.archive_file.pet_script.output_path 
                                  #instead of "${path.module}/myzip/pet_info.zip" so that I only have to change it in one place,
                                  #which would be "data" above.
                                  #I cannot just do filename = output_path, because if there are multiple output paths, VScode
                                  #won't know which one it is to use. So I must tell it filename = archive_file.pet_script.output_path
  filename                       = data.archive_file.pet_script.output_path  #"${path.module}/myzip/pet_info.zip"
  function_name                  = "My_Lambda_function"
  role                           = aws_iam_role.lambda_role.arn #what is .arn
  handler                        = "index.lambda_handler"
  runtime                        = "python3.8" #how do I know this is the right version??
  depends_on                     = [aws_iam_role_policy_attachment.policy_attach]
  #creates a crazy crunch of numbers/letters so that lambda/terraform knows a change has happened when applying
  source_code_hash                           = data.archive_file.pet_script.output_base64sha256
}

# I have made a resource/role. called lambda_role
# THEN. I gave it a policy. Nae, I gave it two. 
# Then, I made policy attachements, to link them to my lambda_role. YES 
# THEN I made the backend to tell it where to look (ireland) 
# Then I did terraform plan, and terraform apply to push this into AWS.
# My next step is to download the sample json file, and upload it to the s3 bucket. then create a script
# to read it. I can go into the console under lambda > functions > my function, and hit test to run it. 
# very exciting! 