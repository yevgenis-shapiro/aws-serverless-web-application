<img width="1680" height="945" alt="image" src="https://github.com/user-attachments/assets/f469dbd8-bf80-4a81-b74e-411b41685253" />


### AWS | Web Application
In this example, you will see a demo architecture for a serverless web application. You can add Amazon Cognito for authentication and add Amazon Simple Storage Service (Amazon S3) and Amazon CloudFront to quickly serve up static content from anywhere


#### 🚀 Key Components:
   - **Amazon S3 + CloudFront** 
   - **AWS API Gateway**
   - **Amazon DynamoDB**
   - **AWS Lambda**
   - **Amazon Cognito**
   - **Amazon SQS**


#### Modules

This setup is composed of several sub-modules that work together to create a complete web application environment:

| Module | Description |
|--------|-------------|
| `CloudFront` | CDN distribution with Origin Access Identity for secure S3 access |
| `Cognito` | User pool for authentication with email verification |
| `S3` | GraphQL API with real-time subscriptions |
| `API Gateway` |REST API with Cognito authorization |
| `SQS` | Message queue for asynchronous processing |
| `Lambda` | Function triggered by SQS messages |
| `DynamoDB` |  NoSQL database for data storage |


⚙️ To use this:
```
To use this:
Create a schema.graphql file for your AppSync API
Create Lambda deployment packages (stream_processor.zip and appsync_resolver.zip)
```


🧱 Deployment
```
terraform init
terraform validate
terraform plan -var-file="template.tfvars"
terraform apply -var-file="template.tfvars" -auto-approve
```




