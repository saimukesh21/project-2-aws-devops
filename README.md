\# AWS Infrastructure Reliability \& Operations Platform



\## Overview



This project demonstrates the design, deployment, monitoring, automation, and operational management of AWS infrastructure using Infrastructure as Code and AWS DevOps services.



The platform provisions AWS infrastructure with Terraform and CloudFormation, configures Linux servers using Ansible and Bash, manages the EC2 instance through AWS Systems Manager, and implements monitoring, alerting, scheduled automation, and basic cost optimization.



\## Architecture



```text

&#x20;                        GitHub

&#x20;                           |

&#x20;                           v

&#x20;                      Terraform

&#x20;                           |

&#x20;                           v

&#x20;                        AWS VPC

&#x20;                           |

&#x20;            +--------------+--------------+

&#x20;            |                             |

&#x20;      Public Subnets                Private Subnets

&#x20;            |                             |

&#x20;       Application ALB                 RDS MySQL

&#x20;            |

&#x20;         EC2 Linux

&#x20;            |

&#x20;     +------+-------+

&#x20;     |              |

&#x20;    SSM          Ansible

&#x20;     |

&#x20;    Bash



CloudWatch

&#x20;   |

&#x20;   v

High CPU Alarm

&#x20;   |

&#x20;   v

&#x20;  SNS

&#x20;   |

&#x20;   v

Email Alert





EventBridge Schedule

&#x20;       |

&#x20;       v

&#x20;     Lambda

&#x20;       |

&#x20;       v

&#x20;  EC2 Start/Stop

&#x20;       |

&#x20;       v

Cost Optimization

```



\## Technologies Used



\* AWS

\* Terraform

\* AWS CloudFormation

\* Amazon VPC

\* Amazon EC2

\* Application Load Balancer

\* Amazon RDS MySQL

\* AWS IAM

\* Amazon S3

\* AWS Systems Manager Session Manager

\* Ansible

\* Bash

\* Amazon CloudWatch

\* Amazon SNS

\* Amazon EventBridge

\* AWS Lambda

\* Git

\* GitHub



\## Infrastructure Provisioning



Terraform provisions the main AWS infrastructure:



\* VPC

\* Public and private subnets

\* Internet Gateway

\* Route tables

\* IAM role and instance profile

\* EC2 instance

\* Security groups

\* Application Load Balancer

\* Target group and listener

\* S3 bucket

\* RDS MySQL database



The infrastructure is organized as reusable Terraform configuration and can be managed through Terraform lifecycle commands.



\## CloudFormation



CloudFormation is used for an operations logging component.



It creates:



\* CloudWatch Log Group

\* `/project-2/operations`

\* 7-day log retention



This demonstrates using both Terraform and CloudFormation for Infrastructure as Code.



\## EC2 and Linux Administration



A Linux EC2 instance hosts the application web server.



Nginx is installed and managed on the instance.



Linux administration tasks are performed using:



\* AWS Systems Manager

\* Ansible

\* Bash



\## AWS Systems Manager



The EC2 instance is registered with Systems Manager and managed using Session Manager.



SSM was also tested by executing Linux commands remotely and verifying successful command execution.



This provides secure remote administration without requiring SSH access.



\## Ansible



Ansible is used to configure the Linux EC2 instance through AWS Systems Manager.



The project includes:



```text

ansible/

├── ansible.cfg

├── configure.yml

└── inventory.aws\_ec2.yml

```



Dynamic AWS EC2 inventory is used to identify the managed instance.



\## Bash Automation



The project includes operational Bash scripts:



```text

scripts/

├── check\_disk.sh

├── check\_nginx.sh

└── system\_info.sh

```



These scripts provide basic Linux health and administration checks.



\## Monitoring and Alerting



CloudWatch monitors EC2 CPU utilization.



A high CPU alarm is configured with:



\* Metric: `CPUUtilization`

\* Threshold: 70%

\* Evaluation period: 1

\* Period: 5 minutes

\* Comparison: Greater Than Threshold



The alarm sends notifications through the SNS topic:



```text

project-2-alerts

```



The alarm-to-SNS path was tested as part of the incident testing process.



\## EventBridge and Lambda Automation



Amazon EventBridge schedules EC2 start and stop operations through AWS Lambda.



Lambda function:



```text

project-2-ec2-scheduler

```



The Lambda function supports:



```json

{

&#x20; "action": "start"

}

```



and:



```json

{

&#x20; "action": "stop"

}

```



Scheduled automation:



\* EC2 start: 9:00 AM IST

\* EC2 stop: 7:00 PM IST



This reduces unnecessary EC2 runtime outside the intended operating period.



\## Cost Optimization



Basic cost optimization is implemented through scheduled EC2 start/stop automation.



The EC2 instance is automatically started during the planned operating period and stopped outside that period.



Additional cost-conscious configuration includes:



\* `t3.micro` EC2 instance

\* `db.t3.micro` RDS instance

\* 20 GB RDS storage

\* Single-AZ RDS deployment

\* 7-day CloudWatch log retention



\## Incident Testing



The project includes operational testing for:



\### Test 1 — CloudWatch Alarm



The CloudWatch high CPU alarm was placed into an alarm state to verify the monitoring and notification path.



```text

EC2 metric

&#x20;  |

CloudWatch Alarm

&#x20;  |

SNS

&#x20;  |

Email

```



\### Test 2 — Systems Manager



SSM was used to execute Linux commands remotely on the EC2 instance.



The command execution completed successfully.



\### Test 3 — EventBridge and Lambda



EventBridge rules and Lambda targets were verified for the scheduled EC2 start/stop automation.



```text

EventBridge

&#x20;    |

&#x20;    v

Lambda

&#x20;    |

&#x20;    v

EC2

```



\## Project Structure



```text

project-2-aws-devops/

│

├── ansible/

│   ├── ansible.cfg

│   ├── configure.yml

│   └── inventory.aws\_ec2.yml

│

├── cloudformation/

│   └── operations-logging.yaml

│

├── lambda/

│   ├── alarm.json

│   └── ec2\_scheduler.py

│

├── scripts/

│   ├── check\_disk.sh

│   ├── check\_nginx.sh

│   └── system\_info.sh

│

├── terraform/

│   ├── main.tf

│   ├── outputs.tf

│   ├── providers.tf

│   └── variables.tf

│

├── .gitignore

└── README.md

```



\## Security



Security controls implemented in the project include:



\* IAM roles for EC2 and Lambda

\* AWS Systems Manager instead of direct SSH administration

\* RDS deployed in private subnets

\* RDS access restricted to the EC2 security group

\* EC2 HTTP access restricted to the ALB security group

\* S3 public access blocked

\* S3 server-side encryption enabled

\* Sensitive Terraform variables excluded from Git

\* Terraform state excluded from Git



\## Key Outcomes



This project demonstrates practical experience with:



\* Infrastructure as Code

\* AWS networking

\* Linux administration

\* Configuration management

\* Secure remote management

\* Monitoring and alerting

\* Serverless automation

\* Scheduled infrastructure operations

\* Basic cloud cost optimization

\* Incident testing

\* Git-based infrastructure management



\## Cleanup



After completing testing and collecting project evidence, AWS resources should be removed when they are no longer required to avoid unnecessary cloud charges.



Terraform-managed resources can be removed with:



```bash

terraform destroy

```



Manually created AWS resources such as EventBridge rules, Lambda resources, SNS resources, and the CloudFormation stack should also be removed if they are not managed by Terraform.



\## Disclaimer



This project is a learning and portfolio project created to demonstrate AWS and DevOps infrastructure, automation, monitoring, and operational practices.



