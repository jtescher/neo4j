#
# Cookbook Name:: neo4j
# Recipe:: default
#
# Copyright (C) 2013 Julian Tescher
#
# License: MIT
#

ruby_block  "set-env-neo4j-home" do
  block do
    ENV["NEO4J_HOME"] = node[:neo4j][:neo4j_home]
  end
  not_if { ENV["NEO4J_HOME"] == node[:neo4j][:neo4j_home] }
end

directory "/etc/profile.d" do
  mode 00755
end

file "/etc/profile.d/neo4j.sh" do
  content "export NEO4J_HOME=#{node[:neo4j][:neo4j_home]}"
  mode 00755
end
