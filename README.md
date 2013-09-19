
This example shows how Rundeck can manage multiple
tomcat instances on single nodes. This can be useful
if one prefers to manage services as if they were
deployed to their own nodes, though physically they
share a common host.

## Requirements

* Vagrant installed to run the VMs
* Internet access to download needed software (automated).

## Configuration

The vagrant config defines three VMs:

* b2d: The "build to deployment" server running Rundeck and Jenkins.
* app1: The first app server running tomcats 1 and 2
* app2: The second app server running tomcats 1 and 2

## Startup

To bring up the 3 VMs, run:

    vagrant up 

After the b2d VM is running, you can login to Jenkins and Rundeck:

* [jenkins](http://192.168.50.4:8080)
* [rundeck](http://192.168.50.4:4440)

You can also access the simple pages:

* app1-tomcat1: http://192.168.50.11:18080/simple-1.0.0/
* app1-tomcat2: http://192.168.50.11:28080/simple-1.0.0/
* app2-tomcat1: http://192.168.50.12:18080/simple-1.0.0/
* app2-tomcat2: http://192.168.50.12:28080/simple-1.0.0/

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






