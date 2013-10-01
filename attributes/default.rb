# Neo4j DB config
default[:neo4j][:version]                       = '1.9.4'
default[:neo4j][:neo4j_home]                    = '/opt/neo4j'
default[:neo4j][:user]                          = 'neo4j'
default[:neo4j][:group]                         = 'neo4j'
default[:neo4j][:nofile_limit]                  = 40000

# Neo4j Wrapper config
default[:neo4j][:java_maxmemory]                = '64'

# Server Neo4j Server config
default[:neo4j][:database_location]             = 'data/graph.db'
default[:neo4j][:webserver_address]             = 'localhost'
default[:neo4j][:webserver_port]                = 7474
default[:neo4j][:webadmin_data_uri]             = '/db/data/'
default[:neo4j][:webadmin_management_uri]       = '/db/manage/'
default[:neo4j][:webserver_limit_executiontime] = 30_000

# Instance Neo4j config
default[:neo4j][:keep_logical_logs]             = 'true'
default[:neo4j][:online_backup_enabled]         = 'true'
default[:neo4j][:online_backup_server]          = '127.0.0.1:6362'
default[:neo4j][:ha][:enable]                   = true
default[:neo4j][:ha][:server_id]                = 1
default[:neo4j][:ha][:cluster_server]           = ':5001-5099'
default[:neo4j][:ha][:server]                   = ':6001'
default[:neo4j][:ha][:initial_hosts]            = ':5001,:5002,:5003'
default[:neo4j][:ha][:pull_interval]            = '10'
default[:neo4j][:ha][:tx_push_factor]           = 1
default[:neo4j][:ha][:execution_guard_enabled]  = true
