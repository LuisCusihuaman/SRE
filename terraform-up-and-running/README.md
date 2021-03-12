<!-- TITLE --> <h1 align="center"> TERRAFORM: UP & RUNNING: WRITING INFRASTRUCTURE AS CODE</h1>

<!-- SUMMARY -->

All the knowledge gathered came in this module was thanks to the following material:

[Terraform: Up & Running, 2nd Edition](https://www.oreilly.com/library/view/terraform-up/9781492046899/)

_In each domain I created demos in terraform and I learnt devops concepts to strengthen my experience._

## 🚀 What I learned

**Chapter 3, How to Manage Terraform State**

What Terraform state is; how to store state so that multiple team members can access it; how to lock state files to prevent race conditions; how to manage secrets with Terraform; a best-practices file and folder layout for Terraform projects; how to use read-only state.

-   📂 **03\-terraform\-state**
    -   📂 [**file\-layout\-example/global/s3**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/03-terraform-state/file-layout-example/global/s3)

**Chapter 4, How to Create Reusable Infrastructure with Terraform Modules**

What modules are; how to create a basic module; how to make a module configurable with inputs and outputs; local values; versioned modules; module gotchas; using modules to define reusable, configurable pieces of infrastructure.

-   📂 **04\-terraform\-module**
    -   📂 [**module\-example/stage/services/webserver\-cluster**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/04-terraform-module/module-example/stage/services/webserver-cluster)

**Chapter 5, Terraform Tips and Tricks: Loops, If-Statements, Deployment, and Gotchas**

Loops with the count parameter, for_each and for expressions; conditionals with the count parameter, for_each and for expressions; built-in functions; common Terraform gotchas and pitfalls, how valid plans can fail, refactoring problems, and eventual consistency.

-   📂 **05\-tips\-and\-tricks**
    -   📂 **zero\-downtime\-deployment/live/stage**
        -   📂 [**data\-stores/mysql**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/05-tips-and-tricks/zero-downtime-deployment/live/stage/data-stores/mysql)
        -   📂 [**services/webserver\-cluster**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/05-tips-and-tricks/zero-downtime-deployment/live/stage/services/webserver-cluster)

**Chapter 6, Production-Grade Terraform Code**

Why DevOps projects always take longer than you expect; the production-grade infrastructure checklist; how to build Terraform modules for production; small modules; composable, testable and releasable modules; Terraform Registry; Terraform escape hatches.

-   📂 **06\-production\-grade\-infrastructure**
    -   📂 **small\-modules/examples**
        -   📂 [**alb**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/06-production-grade-infrastructure/small-modules/examples/alb)
        -   📂 [**asg**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/06-production-grade-infrastructure/small-modules/examples/asg)
        -   📂 [**mysql**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/06-production-grade-infrastructure/small-modules/examples/mysql)

**Chapter 7, How to Test Terraform Code**

Manual tests for Terraform code; sandbox environments and cleanup; automated tests for Terraform code; Terratest; unit, integration, end-to-end tests, running tests in parallel; test stages; retries; the test pyramid; static analysis; property checking.

-   📂 **07\-testing\-terraform\-code**
    -   📂 [**live/stage/services/hello-world-app**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/07-testing-terraform-code/live/stage/services/hello-world-app)
    -   📂 [**test**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/07-testing-terraform-code/test)

**Chapter 8, How to Use Terraform as a Team**

How to adopt Terraform as a team; how to convince your boss; a workflow for deploying application code; version control; coding guidelines; Terraform style; CI/CD for Terraform; the deployment process.

-   📂 **08\-terraform\-team**
    -   📂 [**live/stage/services/hello-world-app**](https://github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/08-terraform-team/live/stage/services/hello-world-app)
