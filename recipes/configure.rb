#
# Cookbook Name:: neo4j
# Recipe:: configure
#
# Copyright (C) 2013 Julian Tescher
#
# License: MIT
#

# Neo4j server properties config
template "#{node[:neo4j][:neo4j_home]}/conf/neo4j-server.properties" do
  source 'neo4j-server.properties.erb'
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

# Grab ha config from OpsWorks if available
if node[:neo4j][:ha][:enable] && node.attribute?(:opsworks)
  layers = node[:opsworks][:layers].keys
  private_ip_addresses = [node[:opsworks][:instance][:private_ip]]
  layers.each do |layer|
    instances = node[:opsworks][:layers][layer][:instances].keys
    instances.each do |instance|
      private_ip_addresses << node[:opsworks][:layers][layer][:instances][instance][:private_ip]
    end
  end
  ha_server_id = node[:opsworks][:instance][:private_ip].split('.').map(&:to_i).inject(:+)
  ha_cluster_server = "#{node[:opsworks][:instance][:private_ip]}:5001"
  ha_server = "#{node[:opsworks][:instance][:private_ip]}:6361"
  ha_initial_hosts = private_ip_addresses.map {|private_ip| "#{private_ip}:5001" } .join(',')
else
  ha_server_id = node[:neo4j][:ha][:server_id]
  ha_cluster_server = node[:neo4j][:ha][:cluster_server]
  ha_server = node[:neo4j][:ha][:server]
  ha_initial_hosts = node[:neo4j][:ha][:initial_hosts]
end

# Neo4j instance properties config
template "#{node[:neo4j][:neo4j_home]}/conf/neo4j.properties" do
  source 'neo4j.properties.erb'
  mode 0444
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  variables(
    :keep_logical_logs => node[:neo4j][:keep_logical_logs],
    :online_backup_enabled => node[:neo4j][:online_backup_enabled],
    :online_backup_server => node[:neo4j][:online_backup_server],
    :enable_ha => node[:neo4j][:ha][:enable],
    :ha_server_id => ha_server_id,
    :ha_cluster_server => ha_cluster_server,
    :ha_server => ha_server,
    :ha_initial_hosts => ha_initial_hosts,
    :ha_pull_interval => node[:neo4j][:ha][:pull_interval],
    :ha_tx_push_factor => node[:neo4j][:ha][:tx_push_factor]
  )
end

# Neo4j wrapper config
template "#{node[:neo4j][:neo4j_home]}/conf/neo4j-wrapper.conf" do
  source 'neo4j-wrapper.conf.erb'
  mode 0444
  owner node[:neo4j][:user]
  group node[:neo4j][:group]
  variables(
    :java_maxmemory => node[:neo4j][:java_maxmemory]
  )
end