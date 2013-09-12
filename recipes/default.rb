#
# Cookbook Name:: neo4j
# Recipe:: default
#
# Copyright (C) 2013 Julian Tescher
# 
# License: MIT
#

include_recipe 'apt'
include_recipe 'java'

include_recipe 'neo4j::install'
include_recipe 'neo4j::configure'

# Start Neo4j
execute './neo4j-service start' do
  user node[:neo4j][:user]
  group node[:neo4j][:group]
  cwd '/etc/init.d'
  not_if { File.exists?("#{node[:neo4j][:neo4j_home]}/data/neo4j-service.pid") }
end
