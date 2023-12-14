# Vivid Arts Studio

## Collaborators
1. Anthony Kioko 

## Project Overview

1. Containerization:
Often, it is challenging to collaborate on a project with different systems. Through containerization, project specific dependancies can be installed and collaboration is made seamless. 

2. Automated Photo Editing Workflow:
 An automated editing workflow initiated by any file uploads to s3 through a Lambda function. Editing tools will be initiated once the function is invoked. 

3. User-Friendly Interface
Once a photo is uploaded to the S3 bucket, an SNS push notification will be sent to notify the client/photographer that their image is uploaded and ready for editing. 

4. Cloud Storage for Accessibility:
Client/Photographer images will be stored in S3. This option is highly scalable and accessible and will incur the least charges. A bucket lifecycle configuration will be implemented to move images to S3 Glacier after 30 days of inactivity. After 90 days, they will be deleted. 

5. Infrastructure as Code (IaC):
The required infrastructure will  be provisioned through a terraform script. This will automate the process and make it easier to monitor deployed resources. 

6. Monitoring and Analytics:
Insights will be gathered through Cloudwatch Logs saved to S3. These will make it easier to monitor bottlenecks and problems that arise. Distributed tracing will also be achieved through AWS X-Ray when making improvements on how requests move through the website. 

7. Continuous Integration/Continuous Deployment(CI/CD):
A CI/CD pipeline will be implemented using AWS Pipeline. Each stage will require automated approvals through testing and thus a faster development cycle. 

## Getting Started


