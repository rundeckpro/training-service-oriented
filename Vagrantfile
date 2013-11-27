
Vagrant.configure("2") do |config|
  config.vm.box = "CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box"

  PROJECT="simple"
  #RUNDECK_YUM_REPO="https://bintray.com/rundeck/candidate-rpm/rpm"
  RUNDECK_YUM_REPO="https://bintray.com/gschueler/ci-rundeck2-rpm/rpm"


  RUNDECK_IP="192.168.50.4"

  config.vm.define :b2d do |b2d|
    b2d.vm.hostname = "b2d"
    b2d.vm.network :private_network, ip: "#{RUNDECK_IP}"
    b2d.vm.provision :shell, :path => "provisioning/install-jenkins.sh", :args => "#{RUNDECK_IP}"
    b2d.vm.provision :shell, :path => "provisioning/install-rundeck.sh", :args => "b2d #{RUNDECK_IP} #{RUNDECK_YUM_REPO}"
    b2d.vm.provision :shell, :path => "provisioning/add-project.sh", :args => "#{PROJECT}"
    b2d.vm.provision :shell, :path => "provisioning/install-httpd.sh"
  end

  config.vm.define :app1 do |app1|
    app1.vm.hostname = "app1"
    app1.vm.network :private_network, ip: "192.168.50.11"
    app1.vm.provision :shell, :path => "provisioning/install-tomcats.sh", :args => "192.168.50.11 http://#{RUNDECK_IP}:4440 #{PROJECT}"
  end

  config.vm.define :app2 do |app2|
    app2.vm.hostname = "app2"
    app2.vm.network :private_network, ip: "192.168.50.12"
    app2.vm.provision :shell, :path => "provisioning/install-tomcats.sh", :args => "192.168.50.12 http://#{RUNDECK_IP}:4440 #{PROJECT}"
  end

end

