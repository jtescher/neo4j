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

include_recipe 'neo4j::install'
include_recipe 'neo4j::configure'

# Symlink neo4j-arbiter script
link '/etc/init.d/neo4j-arbiter' do
  to "#{node[:neo4j][:neo4j_home]}/bin/neo4j-arbiter"
end

# Start the Neo4j Arbiter
execute './neo4j-arbiter start' do
  user node[:neo4j][:user]
  group node[:neo4j][:group]
  cwd '/etc/init.d'
  not_if { File.exists?("#{node[:neo4j][:neo4j_home]}/data/neo4j-arbiter.pid") }
end
