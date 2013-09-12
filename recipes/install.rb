#
# Cookbook Name:: neo4j
# Recipe:: install
#
# Copyright (C) 2013 Julian Tescher
#
# License: MIT
#

# Set $NEO4J_HOME
include_recipe "neo4j::set_neo4j_home"

neo4j_tar_gz = "#{Chef::Config[:file_cache_path]}/neo4j-enterprise-#{node[:neo4j][:version]}.tar.gz"

# Download Neo4j Archive
remote_file neo4j_tar_gz do
  source "http://dist.neo4j.org/neo4j-enterprise-#{node[:neo4j][:version]}-unix.tar.gz"
  action :create_if_missing
end

# Unpack into $NEO4J_HOME
bash "unpack neo4j #{neo4j_tar_gz}" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar -zxf #{neo4j_tar_gz}
    mv neo4j-enterprise-#{node[:neo4j][:version]} #{node[:neo4j][:neo4j_home]}
  EOH
  not_if { ::FileTest.exists?(node[:neo4j][:neo4j_home]) }
end

# Create neo4j user
user node[:neo4j][:user] do
  home    node[:neo4j][:neo4j_home]
  comment "Neo4j Administrator"
  shell   "/bin/bash"
end

# Create the neo4j data directory
directory "#{node[:neo4j][:database_location]}" do
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  mode "0755"
  action :create
  recursive true
end

# Install Neo4j
execute './neo4j install' do
  user 'root'
  group 'root'
  cwd "#{node[:neo4j][:neo4j_home]}/bin"
  creates '/etc/init.d/neo4j-service'
end

# Set memory limits
template "/etc/security/limits.d/#{node[:neo4j][:user]}.conf" do
  source 'neo4j-limits.conf.erb'
  owner node[:neo4j][:user]
  mode  0644
  variables(
    :user => node[:neo4j][:user],
    :nofile_limit => node[:neo4j][:nofile_limit]
  )
end

# Require pam_limits.s
ruby_block "make sure pam_limits.so is required" do
  block do
    fe = Chef::Util::FileEdit.new('/etc/pam.d/su')
    fe.search_file_replace_line(/# session    required   pam_limits.so/, 'session    required   pam_limits.so')
    fe.write_file
  end
end
