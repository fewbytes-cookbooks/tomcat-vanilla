#
# Cookbook Name:: tomcat
# Attributes:: default
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default["tomcat-vanilla"]["enable_https"] = false
default["tomcat-vanilla"]["catalina_options"] = ""

default["tomcat-vanilla"]["connectors"]["ajp"]["redirectPort"] = 8443
default["tomcat-vanilla"]["connectors"]["ajp"]["port"] = 8009

default["tomcat-vanilla"]["connectors"]["http"]["port"] = 8080
default["tomcat-vanilla"]["connectors"]["http"]["proxy_port"] = nil
default["tomcat-vanilla"]["connectors"]["http"]["protocol"] = "org.apache.coyote.http11.Http11Protocol"
default["tomcat-vanilla"]["connectors"]["http"]["connectionTimeout"] = "20000"

default["tomcat-vanilla"]["connectors"]["https"]["port"] = 8443

#TODO: move the percentage of mem to take into an attribute
percentage_of_total_mem = 0.6
total_mem_MB = node["memory"]["total"].sub(/kB$/,'').to_f / 1024
tomcat_heapsize = (total_mem_MB * percentage_of_total_mem).to_i
default["tomcat-vanilla"]["java"]["max_memory_MB"] = tomcat_heapsize
default["tomcat-vanilla"]["java"]["young_gen_MB"] = (tomcat_heapsize * 0.5).to_i
default["tomcat-vanilla"]["java"]["initial_heap_MB"] = [
    [node["tomcat-vanilla"]["java"]["young_gen_MB"] + 200, 1024].max,
    tomcat_heapsize
  ].min
# TODO: Maybe move rendering to recipe
default["tomcat-vanilla"]["java_options"] = "-Xms#{node["tomcat-vanilla"]["java"]["initial_heap_MB"]}M " \
	"-Xmn#{node["tomcat-vanilla"]["java"]["young_gen_MB"]}M " \
	"-Xmx#{node["tomcat-vanilla"]["java"]["max_memory_MB"]}M " \
	"-Djava.awt.headless=true -XX:+UseConcMarkSweepGC"

default["tomcat-vanilla"]["catalina_extra_options"] = {} #additions to JAVA_OPTS for use in catalina through various recipes

default["tomcat-vanilla"]["use_security_manager"] = false
default["tomcat-vanilla"]["authbind"] = "no"
default["tomcat-vanilla"]["deploy_manager_apps"] = true

default["tomcat-vanilla"]["loglevel"] = "INFO"
default["tomcat-vanilla"]["tomcat_auth"] = "true"
default["tomcat-vanilla"]["ajp_enabled"] = true
default["tomcat-vanilla"]["executor_enabled"] = false
default["tomcat-vanilla"]["executor_namePrefix"] = "HTTP"
default["tomcat-vanilla"]["executor_maxThreads"] = 600
default["tomcat-vanilla"]["executor_minSpareThreads"] = 400
default["tomcat-vanilla"]["executor_maxIdleTime"] = 60000
default["tomcat-vanilla"]["valve_enabled"] = false
default["tomcat-vanilla"]["open_file_limit"] = 65536
default["tomcat-vanilla"]["runit_timeout"] = 15
default["tomcat-vanilla"]["regenerate_POLICY_CACHE"] = false
default["tomcat-vanilla"]["user"] = "tomcat"
default["tomcat-vanilla"]["group"] = "tomcat"
default["tomcat-vanilla"]["home"] = "/usr/local/tomcat"
default["tomcat-vanilla"]["base"] = "/var/lib/tomcat"
default["tomcat-vanilla"]["conf_dir"] = "/etc/tomcat"
default["tomcat-vanilla"]["log_dir"] = "/var/log/tomcat"
default["tomcat-vanilla"]["tmp_dir"] = "/tmp/tomcat-tmp"
default["tomcat-vanilla"]["work_dir"] = "/var/cache/tomcat"
default["tomcat-vanilla"]["context_dir"] = "#{node["tomcat-vanilla"]["conf_dir"]}/Catalina/localhost"
default["tomcat-vanilla"]["webapp_dir"] = "/var/lib/tomcat/webapps"
default["tomcat-vanilla"]["keytool"] = "/usr/lib/jvm/default-java/bin/keytool"
default["tomcat-vanilla"]["endorsed_dir"] = "#{node["tomcat-vanilla"]["home"]}/lib/endorsed"

default["tomcat-vanilla"]["tarball_url"] = "http://www.us.apache.org/dist/tomcat/tomcat-7/v7.0.53/bin/apache-tomcat-7.0.53.tar.gz"
default["tomcat-vanilla"]["tarball_checksum"] = "f5e79d70ca7962d11abfc753e47b68a11fdfb4a409e76e2b7bd0a945f80f87c9"
default["tomcat-vanilla"]["version"] = "7.0.53"

# crypto
default["tomcat-vanilla"]["ssl_cert_file"] = nil
default["tomcat-vanilla"]["ssl_key_file"] = nil
default["tomcat-vanilla"]["ssl_chain_files"] = [ ]
default["tomcat-vanilla"]["keystore_pass"] = nil # mandatory for https
default["tomcat-vanilla"]["keystore_file"] = ::File.join(node["tomcat-vanilla"]["conf_dir"], "keystore.jks")
default["tomcat-vanilla"]["keystore_type"] = "jks"
# The keystore and truststore passwords should be generated by the
# openssl cookbook's secure_password method in a recipe if they are
# not otherwise set. Do not hardcode passwords in the cookbook.
default["tomcat-vanilla"]["keystore_password"] = "changeit"
default["tomcat-vanilla"]["truststore_password"] = "changeit"
default["tomcat-vanilla"]["truststore_file"] = nil
default["tomcat-vanilla"]["truststore_type"] = "jks"
default["tomcat-vanilla"]["certificate_dn"] = "cn=localhost"

# JMX
default["tomcat-vanilla"]["jmx"]["enabled"] = true
default["tomcat-vanilla"]["jmx"]["port"] = 9001
default["tomcat-vanilla"]["jmx"]["authenticate"] = true
default["tomcat-vanilla"]["jmx"]["password"] = "unprodigiousandrenidaereenjoinunmistakingly"
default["tomcat-vanilla"]["jmx"]["user"] = "monitorRole"
default["tomcat-vanilla"]["jmx"]["control_password"] = "k298usljksd092lkjs09u23k09sdsdkl8lkjsd98u0wljdgflka"
default["tomcat-vanilla"]["jmx"]["control_user"] = "controlRole"
default["tomcat-vanilla"]["jmx"]["password_file"] = ::File.join(node["tomcat-vanilla"]["conf_dir"], "jmxremote.password")
default["tomcat-vanilla"]["jmx"]["access_file"] = ::File.join(node["tomcat-vanilla"]["conf_dir"], "jmxremote.access")
default["tomcat-vanilla"]["jmx"]["hostname"] = if cloud and cloud["public_hostname"]
		cloud["public_hostname"]
	else
		ipaddress
	end

default["tomcat-vanilla"]["access_log"]["enabled"] = true
default["tomcat-vanilla"]["access_log"]["options"]["pattern"] = "combined"

default["tomcat-vanilla"]["environment"] = {}

default["tomcat-vanilla"]["authbind"] = false
default["tomcat-vanilla"]["authbind_ports"] = []  # eg. [80, 443]
