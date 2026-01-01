# Purpose:  
- Develop a system that communicates with LLMs to establish and manage the state of a fictional setting, and which can create dynamic conversational dialog and static text (Eg newspapers, signs, etc.) based on the current state of the setting. The system should preserve elements of previous character-character interactions—either through entire conversation histories, or through condensed summaries if space or context size is an issue.  It should be setting and product neutral, with an exposed API that external applications like games can interact with easily.



# Minimum Viable Product: 
- The application itself should have bare minimum functionality–the priority is the infrastructure.   A functioning MVP should have a prompt that accepts a Fictional Setting, which it should use to auto generate a character for the user to interact with.  After the setting has been established, the character greets the User with a brief description of the character’s generated bio, and then accepts subsequent prompts in a conversational form.

## The infrastructure should be comprised of the following services/service equivalents in a different format:

* A frontend UI to facilitate User Input.
* An application framework to glue the user interface as well as facilitate requests both back to the user and to and from aws services
* An ECR instance to store the docker image of the application
* An AWS App Runner instance for the docker image to be run on
* An S3 bucket or dynamodb schema to contain conversation context information and history
* API calls to AWS Bedrock for LLM interaction
* (Optional?) Redis for caching
* Terraform configuration files to establish the services and IAM roles required
