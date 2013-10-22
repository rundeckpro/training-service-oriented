This example shows how Rundeck can manage multiple
tomcat instances on single nodes. This can be useful
if one prefers to manage services as if they were
deployed to their own nodes, though physically they
share a common host.

The example also includes a simple example 
"Remote Script Node Step" plugin. The plugin executes
python script on remote nodes.

## Requirements

* Vagrant installed to run the VMs
* Internet access to download needed software (automated).

## Configuration

The vagrant config defines three VMs:

* b2d: The "build to deployment" server running Rundeck and Jenkins.
* app1: The first app server running tomcats 1 and 2
* app2: The second app server running tomcats 1 and 2

## Bootstrap

Check out the source files for these examples:

    git clone https://github.com/simplifyops/training-service-oriented

Then change the working directory:

    cd training-service-oriented
    
## Startup

Bring up the 3 VMs:

    vagrant up 

After the b2d VM is running, you can login to Jenkins and Rundeck:

* [jenkins](http://192.168.50.4:8080) (login: anonymous)
* [rundeck](http://192.168.50.4:4440) (login: admin/admin)

You can also access the simple pages:

* app1-tomcat1: http://192.168.50.11:18080/simple/
* app1-tomcat2: http://192.168.50.11:28080/simple/
* app2-tomcat1: http://192.168.50.12:18080/simple/
* app2-tomcat2: http://192.168.50.12:28080/simple/

## Running the example

1. Login to Rundeck and run the "status" job
2. In Jenkins, run a couple of builds for the "simple" project
3. Login to Rundeck and run the "deploy" job using one of the builds

## Service oriented resource model

Each tomcat instance is modeled as a Rundeck node. This
makes it possible to execute job steps within just the 
scope of each tomcat instance.

To better isolate each tomcat instance from each other
co-located on the same host, a separate system login is
provided for each instance.

## Provisioning 

The provisioning process breaks down into setting up the three
VMs. The first one, b2d, uses three scripts:

* install-jenkins.sh: Installs the jenkins RPM and starts the service. 
TODO: should install the Rundeck plugin and load the simple build job.
* install-rundeck.sh: Installs the rundeck RPMs and starts the service.
* add-project.sh: Creates a working project.

While on the app1 and app2 nodes, the following is used:

* install-tomcats.sh: Installs two tomcat instances on each host.
Also installs the rundeck-admin module to create the resource model nodes.

## TODO

Use Jenkins plugin for artifact URL. eg

* http://192.168.50.4:8080/plugin/rundeck/options/artifact?project=simple

