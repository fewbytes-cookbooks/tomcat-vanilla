#
# Cookbook Name:: tomcat-vanilla
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "tomcat-vanilla::authbind" if node["tomcat-vanilla"]["authbind"]
include_recipe "tomcat-vanilla::service"
