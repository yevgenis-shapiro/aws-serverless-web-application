
# DynamoDB Table
resource "aws_dynamodb_table" "app_table" {
  name           = "${var.project_name}-${var.environment}-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  range_key      = "timestamp"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "user_id"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.project_name}-table"
    Environment = var.environment
  }
}

# Elasticsearch Domain
resource "aws_elasticsearch_domain" "app_es" {
  domain_name           = "${var.project_name}-${var.environment}-search"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type  = "t3.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp3"
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = var.es_master_password
    }
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "es:*"
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.project_name}-${var.environment}-search/*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-elasticsearch"
    Environment = var.environment
  }
}

variable "es_master_password" {
  description = "Master password for Elasticsearch"
  type        = string
  sensitive   = true
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Resource = [
          aws_dynamodb_table.app_table.arn,
          "${aws_dynamodb_table.app_table.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpGet"
        ]
        Resource = "${aws_elasticsearch_domain.app_es.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "pinpoint:PutEvents",
          "pinpoint:UpdateEndpoint"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda Function for DynamoDB Stream Processing
resource "aws_lambda_function" "stream_processor" {
  filename      = "stream_processor.zip"
  function_name = "${var.project_name}-${var.environment}-stream-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 60

  environment {
    variables = {
      ES_ENDPOINT        = aws_elasticsearch_domain.app_es.endpoint
      DYNAMODB_TABLE     = aws_dynamodb_table.app_table.name
      PINPOINT_APP_ID    = aws_pinpoint_app.app_pinpoint.application_id
    }
  }

  tags = {
    Name        = "${var.project_name}-stream-processor"
    Environment = var.environment
  }
}

# Lambda Event Source Mapping for DynamoDB Streams
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.app_table.stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
  batch_size        = 100
}

# Lambda Function for AppSync Data Source
resource "aws_lambda_function" "appsync_resolver" {
  filename      = "appsync_resolver.zip"
  function_name = "${var.project_name}-${var.environment}-appsync-resolver"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE  = aws_dynamodb_table.app_table.name
      ES_ENDPOINT     = aws_elasticsearch_domain.app_es.endpoint
    }
  }

  tags = {
    Name        = "${var.project_name}-appsync-resolver"
    Environment = var.environment
  }
}

# AppSync API
resource "aws_appsync_graphql_api" "app_api" {
  name                = "${var.project_name}-${var.environment}-api"
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  user_pool_config {
    user_pool_id   = aws_cognito_user_pool.app_user_pool.id
    aws_region     = var.aws_region
    default_action = "ALLOW"
  }

  schema = file("${path.module}/schema.graphql")

  tags = {
    Name        = "${var.project_name}-appsync-api"
    Environment = var.environment
  }
}

# AppSync Data Sources
resource "aws_appsync_datasource" "lambda_datasource" {
  api_id           = aws_appsync_graphql_api.app_api.id
  name             = "LambdaDataSource"
  service_role_arn = aws_iam_role.appsync_role.arn
  type             = "AWS_LAMBDA"

  lambda_config {
    function_arn = aws_lambda_function.appsync_resolver.arn
  }
}

resource "aws_appsync_datasource" "dynamodb_datasource" {
  api_id           = aws_appsync_graphql_api.app_api.id
  name             = "DynamoDBDataSource"
  service_role_arn = aws_iam_role.appsync_role.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.app_table.name
  }
}

# IAM Role for AppSync
resource "aws_iam_role" "appsync_role" {
  name = "${var.project_name}-${var.environment}-appsync-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "appsync_policy" {
  name = "${var.project_name}-appsync-policy"
  role = aws_iam_role.appsync_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = aws_lambda_function.appsync_resolver.arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.app_table.arn,
          "${aws_dynamodb_table.app_table.arn}/*"
        ]
      }
    ]
  })
}

# Pinpoint Application
resource "aws_pinpoint_app" "app_pinpoint" {
  name = "${var.project_name}-${var.environment}-analytics"

  tags = {
    Name        = "${var.project_name}-pinpoint"
    Environment = var.environment
  }
}

# Data Source for current AWS account
data "aws_caller_identity" "current" {}
