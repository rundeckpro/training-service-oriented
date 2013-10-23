These examples support Rundeck basic training where you will learn
how Rundeck integrates with other tools, uses Jobs to provide
self serve automation, and how to automate the setup of Rundeck itself.

The example shows Rundeck supporting a continuous delivery process
for a webapp called "simple".
A set of Rundeck jobs  manage the webapp deployed to
a set of tomcat instances in the "simple" app environment. The jobs
handle utility tasks as well as deploy the webapp, 
and manage the app startup and shutdown of the tomcat instances, too.
The webapp deployment can be triggered by a Jenkins build or directly by a user.

The example also shows a flexible way Rundeck can manage tomcat
instances by treating each instance as if it were on its own node.
This can be useful if in some environments tomcat instances share hosts
to minimize foot print or be deployed to their own hosts for isolation or horizontal scaling.

There are a number of interesting integration points between Rundeck and other tools.
The [Jenkins Rundeck plugin](https://wiki.jenkins-ci.org/display/JENKINS/RunDeck+Plugin)
is used to trigger Rundeck job execution, as well as, provide
lists of build artifacts to rundeck jobs.
An Apache httpd instance is used to play the role of a cheap and simple WebDAV repository 
to store scripts and other files shared with Rundeck.

## Requirements
To run the examples ensure you have:

* [Vagrant](http://vagrantup.com) installed to run the VMs
* Internet access to download needed software (automated).

## Bootstrap

Check out the source files for these examples:

    git clone https://github.com/simplifyops/training-service-oriented

Then change the working directory:

    cd training-service-oriented
    
## Boxes

The vagrant config defines three VMs:

* b2d: The "build to deployment" server running Rundeck, Jenkins and httpd.
* app1: The first app server running tomcat intances 1 and 2
* app2: The second app server running tomcat instances 1 and 2

 
### Startup

Bring up the 3 VMs:

    vagrant up 

You should see output similar to:

```
Bringing machine 'b2d' up with 'virtualbox' provider...
Bringing machine 'app1' up with 'virtualbox' provider...
Bringing machine 'app2' up with 'virtualbox' provider...
```

After the b2d VM is running, you can login to Jenkins and Rundeck:

* [jenkins](http://192.168.50.4:8080) (login: anonymous)
* [rundeck](http://192.168.50.4:4440) (login: admin/admin)

You can also access the simple webapp on each tomcat instance:

* app1-tomcat1: http://192.168.50.11:18080/simple/
* app1-tomcat2: http://192.168.50.11:28080/simple/
* app2-tomcat1: http://192.168.50.12:18080/simple/
* app2-tomcat2: http://192.168.50.12:28080/simple/

You can ssh to any of these boxes using `vagrant ssh {box}`. 
For example, to login to b2d box, do:

    vagrant ssh b2d
   
## Running the example

1. Login to Rundeck and run the "status" job
2. In Jenkins, run a couple of builds for the "simple" project
3. Login to Rundeck and run the "deploy" job using one of the builds

## The "simple" project

A Rundeck project called "simple" contains the jobs and nodes to manage the delivery of the "simple" web app.

### Jobs
Seven jobs are loaded into the "simple" project:

* utils/activate_version : activate the app version
* utils/stage_webapp : stage the app 	
* utils/url_exists : check if the url exists
* deploy : deploy the app 	
* start : start the app 	
* status : get the app status 	
* stop : stop the app 	

Several jobs are organized into a "utils" group since they support the other jobs and aren't typically used directly.

### Nodes

The project is configured with a set of nodes that represent the VMs managed by vagrant 
but also nodes that represent each of the tomcat instances.

This _service oriented_ resource model uses the Rundeck Node concept and extends it to represent a software deployment.

Each tomcat instance is modeled as a Rundeck node. This
makes it possible to execute job steps within just the 
node context for each tomcat instance.

The node for each tomcat instance also specifies a different
system login to use to execute the commands. This helps
isolate each tomcat instance from each other
since they are co-located on the same host.

## Under the covers

You might be interested in how this working example was constructed.

Each of the VMs uses a set of provinsiong scripts.
The first server, "b2d", uses three scripts:

* install-jenkins.sh: Installs jenkins via yum and starts the service. 
* install-rundeck.sh: Installs rundeck via yum and starts the service.
* add-project.sh: Creates the working project called "simple" with a set of jobs and nodes.

While on the app1 and app2 VMs, the following script is used:

* install-tomcats.sh: Installs two tomcat instances on each host.
Uses the rundeck-admin module to create nodes for the resource model in the "simple" project.

## TODO

Use Jenkins plugin for artifact URL. eg

* http://192.168.50.4:8080/plugin/rundeck/options/artifact?project=simple

