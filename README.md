# infrastructure

## NOTES/TODOS
- This project does not currently use GitHub actions to deploy changes. In the meantime, alert @gcardona on Code for Philly Slack if you would like to contribute a change and have it deployed.
- This project is intended for infrastructure related to the operation of PHLASK. The actual code to deploy the PHLASK site is on the phlask-map project.
- src_code subfolder READMEs are not available yet. We welcome contributions there!
- A possible future contribution is to add the management of Firebase to this project
- The src_code/image-submission-handler folder currently includes the node_modules that came with the original handcrafted Lambda. This was done to save time for the initial commit. However, we should transition that folder to use a package.json file and perform the download/storage of required npm modules as a part of the Terraform execution. Storing `node_modules` as-is is generally a bad practice and was done because this project has a small amount of modules.

## Structure
### modules
Stores [Terraform Modules](https://developer.hashicorp.com/terraform/tutorials/modules/module) for common resources across PHLASK environments

#### phlask-baseline-resources
A Terraform module to store baseline resources required for any PHLASK environment

### src_code
The source code for PHLASK Lambda functions. These should each have their own README file to explain the function's purpose.

### env_name files
These files store the Terraform configuration specific to a given environment (test/beta/prod). This allows us to make environment-specific changes for testing before moving those changes to upper environments.

### lambda-* files
These files store the configuration required to deploy lambda functions that form part of PHLASK. Many of these support the operation of our test environment.

### common
This file is for common resources that should be used across all PHLASK environments.

### locals
This file is to store [Terraform Locals](https://developer.hashicorp.com/terraform/language/values/locals). These are local variables that are handy when you want to create a complex/dynamic value and propagate it across multiple portions of the Terraform code.

### provider
Configures any [Terraform Providers](https://developer.hashicorp.com/terraform/language/providers) which are the core modules that allow our Terraform code to interact with the systems that Terraform is intended to manage (ex - AWS).

## Project Maintenance
### Updating Terraform lockfile
Ocasionally the Terraform lockfile will need to be updated to ensure we are using the latest version of each provider. To do this locally:
- With a local copy of Terraform: `terraform init -backend=false -upgrade`
- With Docker on MacOS, run the following from the base of this project: `docker run -v $(pwd):/usr/local/src -it --workdir /usr/local/src hashicorp/terraform:1.3.5 init -backend=false -upgrade`