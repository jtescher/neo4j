# Neo4j DB config
set_unless[:neo4j][:version] = '1.9.RC2'
set_unless[:neo4j][:neo4j_home] = '/opt/neo4j'
set_unless[:neo4j][:user] = 'neo4j'
set_unless[:neo4j][:group] = 'neo4j'
set_unless[:neo4j][:nofile_limit] = 40000

# Server Neo4j Server config
set_unless[:neo4j][:database_location] = '/srv/neo4j'
set_unless[:neo4j][:webserver_address] = 'localhost'
set_unless[:neo4j][:webserver_port] = 7474
set_unless[:neo4j][:webadmin_data_uri] = '/db/data/'
set_unless[:neo4j][:webadmin_management_uri] = '/db/manage/'

# Instance Neo4j config
set_unless[:neo4j][:ha][:enable] = true
set_unless[:neo4j][:ha][:server_id] = 1
set_unless[:neo4j][:ha][:initial_hosts] = 'localhost:5001'

# Coordinator config
set_unless[:neo4j][:coordinator][:enable] = false
set_unless[:neo4j][:coordinator][:client_port] = 2181
set_unless[:neo4j][:coordinator][:machine_id] = 1
set_unless[:neo4j][:coordinator][:sync_limit] = 5
set_unless[:neo4j][:coordinator][:init_limit] = 10
set_unless[:neo4j][:coordinator][:tick_time] = 2000
set_unless[:neo4j][:coordinator][:data_dir] = '/srv/neo4j/coordinator'
