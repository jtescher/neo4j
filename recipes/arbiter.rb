#
# Cookbook Name:: neo4j
# Recipe:: arbiter
#
# Copyright (C) 2013 Julian Tescher
#
# License: MIT
#

include_recipe 'apt'
include_recipe 'java'

package "default-jre-headless" do
  action :install
end

include_recipe 'neo4j::install'

# Copy neo4j-arbiter script
template '/etc/init.d/neo4j-arbiter' do
  source 'neo4j-arbiter.erb'
  mode 0744
end

# Start the Neo4j Arbiter
execute './neo4j-arbiter start' do
  user node[:neo4j][:user]
  group node[:neo4j][:group]
  cwd '/etc/init.d'
  not_if { File.exists?("#{node[:neo4j][:neo4j_home]}/data/neo4j-arbiter.pid") }
end
