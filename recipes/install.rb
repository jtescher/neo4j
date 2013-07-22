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

# Neo4j instance properties config
if node[:neo4j][:ha][:enable] && node.attribute?(:opsworks)
  layers = node[:opsworks][:layers].keys
  private_ip_addresses = [node[:opsworks][:instance][:private_ip]]
  layers.each do |layer|
    instances = node[:opsworks][:layers][layer][:instances].keys
    instances.each do |instance|
      private_ip_addresses << node[:opsworks][:layers][layer][:instances][instance][:private_ip]
    end
  end
  initial_hosts = private_ip_addresses.map {|private_ip| "#{private_ip}:5001" } .join(',')

  template "#{node[:neo4j][:neo4j_home]}/conf/neo4j.properties" do
    source 'neo4j.erb'
    mode 0444
    owner node[:neo4j][:user]
    group node[:neo4j][:group]
    variables(
      :enable_ha => node[:neo4j][:ha][:enable],
      :ha_server_id => node[:opsworks][:instance][:private_ip].split('.').map(&:to_i).inject(:+),
      :ha_cluster_server => "#{node[:opsworks][:instance][:private_ip]}:5001",
      :ha_server => "#{node[:opsworks][:instance][:private_ip]}:6361",
      :ha_initial_hosts => initial_hosts,
      :ha_pull_interval => node[:neo4j][:ha][:pull_interval]
    )
  end
else
  template "#{node[:neo4j][:neo4j_home]}/conf/neo4j.properties" do
    source 'neo4j.erb'
    mode 0444
    owner node[:neo4j][:user]
    group node[:neo4j][:group]
    variables(
      :enable_ha => node[:neo4j][:ha][:enable],
      :ha_server_id => node[:neo4j][:ha][:server_id],
      :ha_cluster_server => node[:neo4j][:ha][:cluster_server],
      :ha_server => node[:neo4j][:ha][:server],
      :ha_initial_hosts => node[:neo4j][:ha][:initial_hosts],
      :ha_pull_interval => node[:neo4j][:ha][:pull_interval]
    )
  end
end

# Neo4j wrapper config
template "#{node[:neo4j][:neo4j_home]}/conf/neo4j-wrapper.conf" do
  source 'neo4j-wrapper.conf.erb'
  mode 0444
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
end
