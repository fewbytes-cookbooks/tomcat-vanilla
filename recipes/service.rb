include_recipe "tomcat-vanilla::install"

catalina_options = ([node["tomcat-vanilla"]["catalina_options"]] + \
	node["tomcat-vanilla"]["catalina_extra_options"].values).join(" ")

if node["tomcat-vanilla"]["jmx"]["enabled"]
	catalina_options += " -Dcom.sun.management.jmxremote " \
	"-Dcom.sun.management.jmxremote.port=#{node["tomcat-vanilla"]["jmx"]["port"]} " \
	"-Dcom.sun.management.jmxremote.ssl=false " \
	"-Dcom.sun.management.jmxremote.authenticate=#{node["tomcat-vanilla"]["jmx"]["authenticate"]} " \
	"-Dcom.sun.management.jmxremote.access.file=#{node["tomcat-vanilla"]["jmx"]["access_file"]} " \
	"-Dcom.sun.management.jmxremote.password.file=#{node["tomcat-vanilla"]["jmx"]["password_file"]}" + \
	if node["tomcat-vanilla"]["jmx"]["hostname"]
		" -Djava.rmi.server.hostname=#{node["tomcat-vanilla"]["jmx"]["hostname"]}"
	else
		""
	end
end

runit_service "tomcat" do
	options(
		:user => node["tomcat-vanilla"]["user"],
		:group => node["tomcat-vanilla"]["group"], 
		:catalina_home => node["tomcat-vanilla"]["home"]
		)
	env({
		"CATALINA_HOME" => node["tomcat-vanilla"]["home"],
		"CATALINA_BASE" => node["tomcat-vanilla"]["base"],
		"JAVA_OPTS" => node["tomcat-vanilla"]["java_options"],
		"CATALINA_OPTS" => catalina_options,
		"JVM_TMP" => node["tomcat-vanilla"]["tmp_dir"],
		"CATALINA_TMPDIR" => node["tomcat-vanilla"]["tmp_dir"],
		"JAVA_HOME" => node["java"]["java_home"],
		"JAVA_ENDORSED_DIRS" => node["tomcat-vanilla"]["endorsed_dir"]
		}.merge(node["tomcat-vanilla"]["environment"].to_hash)
		)
end