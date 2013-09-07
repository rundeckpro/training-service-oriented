
The vagrant config defines three VMs:

* b2d: The "build to deployment" server running Rundeck and Jenkins.
* app1: The first app server running tomcats 1 and 2
* app2: The second app server running tomcats 1 and 2

To bring up the 3 VMs, run:

    vagrant up 

After the b2d VM is running, you can login to Jenkins and Rundeck:

* [jenkins](http://192.168.50.4:8080)
* [rundeck](http://192.168.50.4:4440)



