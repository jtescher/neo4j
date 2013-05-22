@test "tmux is installed and in the path" {
  pid="$(cat /opt/neo4j/data/neo4j-service.pid)"
  result="$(sudo service neo4j-service status)"
   [ "$result" -eq "Neo4j Server is running at pid $pid" ]
}