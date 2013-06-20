# Neo4j DB config
default[:neo4j][:version] = '1.9.RC2'
default[:neo4j][:neo4j_home] = '/opt/neo4j'
default[:neo4j][:user] = 'neo4j'
default[:neo4j][:group] = 'neo4j'
default[:neo4j][:nofile_limit] = 40000

# Server Neo4j Server config
default[:neo4j][:database_location] = '/srv/neo4j'
default[:neo4j][:webserver_address] = 'localhost'
default[:neo4j][:webserver_port] = 7474
default[:neo4j][:webadmin_data_uri] = '/db/data/'
default[:neo4j][:webadmin_management_uri] = '/db/manage/'

# Instance Neo4j config
default[:neo4j][:ha][:enable] = true
default[:neo4j][:ha][:server_id] = 1
default[:neo4j][:ha][:cluster_server] = 'localhost:5001'
default[:neo4j][:ha][:server] = 'localhost:6361'
default[:neo4j][:ha][:initial_hosts] = 'localhost:5001'
default[:neo4j][:ha][:pull_interval] = '0s'
