build_dir = ::File.join(Chef::Config[:file_cache_path], "build", "tomcat-native")

apr_from_source = case node.platform
when "ubuntu"
	node.platform_version >= "13.04"
else
	true
end

if apr_from_source
	directory build_dir do
		recursive true
	end

	include_recipe "build-essential"
	case node.platform_family
	when "debian"
		package "libapr1-dev"
		package "libssl-dev"
	when "rhel"
		package "apr-devel"
		package "openssl-devel"
	end
	bash "build tomcat native extensions" do
		code <<-EOS
		cd #{build_dir}	
		tar -xzf #{::File.join(node["tomcat-vanilla"]["home"], "bin", "tomcat-native.tar.gz")}
		cd tomcat-native-*-src/jni/native
		./configure --with-apr=/usr/bin/apr-config
		make install
		EOS
		creates "/usr/local/apr/lib/libtcnative-1.so"
	end
	link "/usr/lib/libtcnative-1.so" do
		to "/usr/local/apr/lib/libtcnative-1.so"
	end
else
	package "libtcnative-1"
end

node.default["tomcat-vanilla"]["apr_enabled"] = true