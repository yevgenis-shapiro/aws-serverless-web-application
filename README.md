<img width="1680" height="945" alt="image" src="https://github.com/user-attachments/assets/65346b96-31e8-4ff6-9582-1ff8c2e803e5" />

### AWS | Mobile Backend
Web application example, in this example you will see a demo architecture for a serverless mobile backend. For mobile applications, users expect real-time data and a feature-rich user experience. Users also expect their data to be available when they’re offline or using a low-speed connection, and they expect data to be synchronized across devices. You have the added challenge that, with a microservice-based architecture, it takes multiple connections to retrieve distributed data vs. a single connection, which you might use in a more traditional backend. You also need to support a combination of transactional and query data. 

#### 🚀 Key Components:
   - **Amazon S3 + CloudFront** 
   - **Amazon Cognito** 
   - **AWS AppSync**
   - **Amazon DynamoDB**
   - **Amazon Elasticsearch**
   - **AWS Lambda**
   - **Amazon Pinpoint**


#### Modules

This setup is composed of several sub-modules that work together to create a complete web application environment:

| Module | Description |
|--------|-------------|
| `CloudFront` | Static content delivery with CDN |
| `Cognito` | User authentication and authorization |
| `AppSync` | GraphQL API with real-time subscriptions |
| `DynamoDB` | NoSQL database with streams enabled |
| `Elasticsearch` | Full-text search and analytics |
| `Lambda` | Stream processor for DynamoDB changes and AppSync resolver for custom business logic |
| `Pinpoint` | Analytics and user engagement |


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




