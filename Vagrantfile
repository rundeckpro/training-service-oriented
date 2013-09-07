
Vagrant.configure("2") do |config|
  config.vm.box = "CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box"

  PROJECT="examples"
  RUNDECK_YUM_REPO="https://bintray.com/rundeck/ci-staging-rpm/rpm"

  config.vm.define :b2d do |b2d|
    b2d.vm.hostname = "b2d"
    b2d.vm.network :private_network, ip: "192.168.50.4"
    b2d.vm.provision :shell, :path => "install-jenkins.sh"    
    b2d.vm.provision :shell, :path => "install-rundeck.sh", :args => "b2d 192.168.50.4 #{RUNDECK_YUM_REPO}"
    b2d.vm.provision :shell, :path => "add-project.sh", :args => "#{PROJECT}"
  end

  config.vm.define :app1 do |app1|
    app1.vm.hostname = "app1"
    app1.vm.network :private_network, ip: "192.168.50.10"
    app1.vm.provision :shell, :path => "install-tomcats.sh", :args => "192.168.50.10 http://192.168.50.4:4440 #{PROJECT}"
  end

  config.vm.define :app2 do |app2|
    app2.vm.hostname = "app2"
    app2.vm.network :private_network, ip: "192.168.50.11"
    app2.vm.provision :shell, :path => "install-tomcats.sh", :args => "192.168.50.11 http://192.168.50.4:4440 #{PROJECT}"
  end

end

