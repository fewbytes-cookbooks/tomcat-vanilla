apt_package "authbind"

directory '/etc/authbind/byport/' do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
end

node["tomcat-vanilla"]["authbind_ports"].each do |p|
    filename = "/etc/authbind/byport/%{port}" % {:port => p} 

    file filename do
        owner node["tomcat-vanilla"]["user"]
        group node["tomcat-vanilla"]["group"]
        mode '0500'
        action :create
    end
end
