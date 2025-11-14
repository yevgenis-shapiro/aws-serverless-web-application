<img width="1680" height="945" alt="image" src="https://github.com/user-attachments/assets/f469dbd8-bf80-4a81-b74e-411b41685253" />


### AWS | Web Application
Web application example, in this example you will see a demo architecture for a serverless mobile backend. For mobile applications, users expect real-time data and a feature-rich user experience. Users also expect their data to be available when they’re offline or using a low-speed connection, and they expect data to be synchronized across devices. You have the added challenge that, with a microservice-based architecture, it takes multiple connections to retrieve distributed data vs. a single connection, which you might use in a more traditional backend. You also need to support a combination of transactional and query data. 

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




