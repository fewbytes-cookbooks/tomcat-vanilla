include_recipe "java"
include_recipe "runit"

major_version = node["tomcat-vanilla"]["version"][/^(\d)\.\d+\.\d+$/, 1]

if ::Chef::Config[:solo] # chef-solo can't save the random generated password for fucture use
  node.set_unless['tomcat-vanilla']['keystore_password'] = "changeit"
  node.set_unless['tomcat-vanilla']['truststore_password'] = "changeit"
else
  ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

  node.set_unless['tomcat-vanilla']['keystore_password'] = secure_password
  node.set_unless['tomcat-vanilla']['truststore_password'] = secure_password
end

group node["tomcat-vanilla"]["group"]

user node["tomcat-vanilla"]["user"] do
  home node["tomcat-vanilla"]["base"]
  gid node["tomcat-vanilla"]["group"]
  system true
end

ark "tomcat" do
	url node["tomcat-vanilla"]["tarball_url"]
	checksum node["tomcat-vanilla"]["tarball_checksum"]
  version node["tomcat-vanilla"]["version"]
	action :install	
end

%w(base work_dir log_dir).each do |dir|
  directory node["tomcat-vanilla"][dir] do
  	owner node["tomcat-vanilla"]["user"]
  	mode "0755"
  end
end

directory ::File.join(node["tomcat-vanilla"]["base"], "lib") do
  mode "0755"
end

directory node["tomcat-vanilla"]["conf_dir"] do
	mode "0755"
end

directory ::File.join(node["tomcat-vanilla"]["conf_dir"], "Catalina") do
	mode "0755"
end

directory ::File.join(node["tomcat-vanilla"]["conf_dir"], "Catalina", "localhost") do
	mode "0755"
end

remote_directory ::File.join(node["tomcat-vanilla"]["conf_dir"]) do
  source "conf"
  mode "0755"
  files_mode "0644"
end

unless node['tomcat-vanilla']["truststore_file"].nil?
  java_options = node['tomcat-vanilla']['java_options'].to_s
  java_options << " -Djavax.net.ssl.trustStore=#{node["tomcat-vanilla"]["conf_dir"]}/#{node["tomcat-vanilla"]["truststore_file"]}"
  java_options << " -Djavax.net.ssl.trustStorePassword=#{node["tomcat-vanilla"]["truststore_password"]}"
  node.set['tomcat']['java_options'] = java_options
end

template ::File.join(node["tomcat-vanilla"]["conf_dir"], "server.xml") do
	notifies :restart, "runit_service[tomcat]"
  source "tomcat#{major_version}-server.xml.erb"
	mode "0644"
end

template "/etc/tomcat/logging.properties" do
  source "logging.properties.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "runit_service[tomcat]"
end

unless node['tomcat-vanilla']["ssl_cert_file"].nil?
  cookbook_file "#{node['tomcat-vanilla']['conf_dir']}/#{node['tomcat-vanilla']['ssl_cert_file']}" do
    mode "0644"
  end
  cookbook_file "#{node['tomcat-vanilla']['conf_dir']}/#{node['tomcat-vanilla']['ssl_key_file']}" do
    mode "0644"
  end
  cacerts = ""
  node['tomcat-vanilla']['ssl_chain_files'].each do |cert|
    cookbook_file "#{node['tomcat-vanilla']['conf_dir']}/#{cert}" do
      mode "0644"
    end
    cacerts = cacerts + "#{cert} "
  end
  script "create_tomcat_keystore" do
    interpreter "bash"
    cwd node['tomcat-vanilla']['conf_dir']
    code <<-EOH
      cat #{cacerts} > cacerts.pem
      openssl pkcs12 -export \
       -inkey #{node['tomcat-vanilla']['ssl_key_file']} \
       -in #{node['tomcat-vanilla']['ssl_cert_file']} \
       -chain \
       -CAfile cacerts.pem \
       -password pass:#{node['tomcat-vanilla']['keystore_password']} \
       -out #{node['tomcat-vanilla']['keystore_file']}
    EOH
    notifies :restart, "service[tomcat]"
    creates node['tomcat-vanilla']['keystore_file']
  end
else
  java_ext_keystore node['tomcat-vanilla']['keystore_file'] do
    cert_alias node.fqdn
    dn node['tomcat-vanilla']['certificate_dn']
    password node['tomcat-vanilla']['keystore_password']
    notifies :restart, "service[tomcat]"
  end
end

if node['tomcat-vanilla']['apr_enabled']
  include_recipe "tomcat-vanilla::apr"
end

unless node['tomcat-vanilla']["truststore_file"].nil?
  cookbook_file "#{node['tomcat-vanilla']['conf_dir']}/#{node['tomcat-vanilla']['truststore_file']}" do
    mode "0644"
  end
end

#allow password-protected remote JMX access
file node["tomcat-vanilla"]["jmx"]["access_file"] do
  owner node["tomcat-vanilla"]["user"]
  group node["tomcat-vanilla"]["group"]
  mode "0400"
  content "#{node["tomcat-vanilla"]["jmx"]["user"]} readonly\n#{node["tomcat-vanilla"]["jmx"]["control_user"]} readwrite\n"
end

file node["tomcat-vanilla"]["jmx"]["password_file"] do
  owner node["tomcat-vanilla"]["user"]
  group node["tomcat-vanilla"]["group"]
  mode "0400"
  content "#{node["tomcat-vanilla"]["jmx"]["user"]} #{node["tomcat-vanilla"]["jmx"]["password"]}\n#{node["tomcat-vanilla"]["jmx"]["control_user"]} #{node["tomcat-vanilla"]["jmx"]["control_password"]}\n"
end

directory node['tomcat-vanilla']['log_dir'] do
  owner node['tomcat-vanilla']['user']
  group node['tomcat-vanilla']['group']
  mode '0755'
  recursive true
end

directory node['tomcat-vanilla']['home'] do
  owner node['tomcat-vanilla']['user']
  group node['tomcat-vanilla']['group']
  mode '0770'
  recursive true
end

directory node['tomcat-vanilla']['tmp_dir'] do
  owner node['tomcat-vanilla']['user']
  group node['tomcat-vanilla']['group']
  mode '0755'
  recursive true
end

link ::File.join(node['tomcat-vanilla']['base'], "logs") do
  to node['tomcat-vanilla']['log_dir']
  notifies :restart, "service[tomcat]"
end

link ::File.join(node['tomcat-vanilla']['base'], "conf") do
  to node['tomcat-vanilla']['conf_dir']
end

link ::File.join(node['tomcat-vanilla']['base'], "work") do
  to node["tomcat-vanilla"]["work_dir"]
end
