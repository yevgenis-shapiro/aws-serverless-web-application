<img width="1680" height="945" alt="image" src="https://github.com/user-attachments/assets/eaac30d4-1911-4a83-ba99-c285c20655a4" />

### AWS | Serverless Web Application
In this example, you will see a demo architecture for a serverless web application. You can add Amazon Cognito for authentication and add Amazon Simple Storage Service (Amazon S3) and Amazon CloudFront to quickly serve up static content from anywhere


#### 🚀 Key Components:
   - **Amazon S3 + CloudFront** 
   - **AWS API Gateway**
   - **Amazon DynamoDB**
   - **AWS Lambda**
   - **Amazon Cognito**
   - **Amazon SQS**



📦 Architecture Flow:
```
Client authenticates via Cognito
Requests go through CloudFront (serving S3 content)
API Gateway receives POST requests (protected by Cognito)
Messages are sent to SQS queue
Lambda processes messages from the queue
Data is stored in DynamoDB
```



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
Create a lambda_function.zip file with your Lambda code
```


🧱 Deployment
```
terraform init
terraform validate
terraform plan -var-file="template.tfvars"
terraform apply -var-file="template.tfvars" -auto-approve
```




