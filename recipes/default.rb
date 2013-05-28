#
# Cookbook Name:: neo4j
# Recipe:: default
#
# Copyright (C) 2013 Julian Tescher
# 
# License: MIT
#

include_recipe 'apt'
include_recipe 'java::openjdk'
include_recipe 'zookeeper'

package "default-jre-headless" do
  action :install
end

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
  home node[:neo4j][:neo4j_home]
  comment "Neo4j Administrator"
  supports :manage_home => false
  system true
end

# Create the neo4j data directory
directory "#{node[:neo4j][:database_location]}" do
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  mode "0755"
  action :create
  recursive true
end

# Create coordinator data directory
directory "#{node[:neo4j][:coordinator][:data_dir]}" do
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  mode 0755
  action :create
  recursive true
end

# Install Neo4j
execute './neo4j install' do
  user 'root'
  group 'root'

  cwd "#{node[:neo4j][:neo4j_home]}/bin"
  creates '/etc/init.d/neo4j-service'

  not_if { node[:neo4j][:coordinator][:enable] }
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

# Neo4j server properties config
template "#{node[:neo4j][:neo4j_home]}/conf/neo4j-server.properties" do
  source 'neo4j-server.erb'
  mode 0444
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  variables(
    :database_location => node[:neo4j][:database_location],
    :webserver_address => node[:neo4j][:webserver_address],
    :webserver_port => node[:neo4j][:webserver_port],
    :webadmin_data_uri => node[:neo4j][:webadmin_data_uri],
    :webadmin_management_uri => node[:neo4j][:webadmin_management_uri],
    :enable_ha => node[:neo4j][:ha][:enable],
    :conf_dir => "#{node[:neo4j][:neo4j_home]}/conf"
  )
end

coordinator_addresses = node[:neo4j][:coordinator][:cluster].map do |address|
  "#{address}:#{node[:neo4j][:coordinator][:port]}"
end.join(',')

# Neo4j instance properties config
template "#{node[:neo4j][:neo4j_home]}/conf/neo4j.properties" do
  source "neo4j.erb"
  mode 0444
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  variables(
    :ha_initial_hosts => node[:neo4j][:ha][:initial_hosts],
    :coordinator_addresses => coordinator_addresses
  )
end

# High Availability Neo4j Coordinator config
template "#{node[:neo4j][:neo4j_home]}/conf/coord.cfg" do
  source 'coord_cfg.erb'
  mode 0644
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  variables(
    :cluster_addresses => node[:neo4j][:coordinator][:cluster],
    :client_port =>node[:neo4j][:coordinator][:client_port],
    :sync_limit => node[:neo4j][:coordinator][:sync_limit],
    :init_limit => node[:neo4j][:coordinator][:init_limit],
    :tick_time => node[:neo4j][:coordinator][:tick_time],
    :data_dir => node[:neo4j][:coordinator][:data_dir]
  )
end

# Start Neo4j
execute './neo4j-service start' do
  user node[:neo4j][:user]
  group node[:neo4j][:group]

  cwd '/etc/init.d'

  not_if { node[:neo4j][:coordinator][:enable] || File.exists?("#{node[:neo4j][:neo4j_home]}/data/neo4j-service.pid") }
end

# Start the Neo4j Coordinator, if this is a coordinator node
execute './neo4j-coordinator start' do
  user node[:neo4j][:user]
  group node[:neo4j][:group]

  cwd '/etc/init.d'

  only_if { node[:neo4j][:coordinator][:enable] && !File.exists?("#{node[:neo4j][:neo4j_home]}/data/neo4j-service.pid") }
end
