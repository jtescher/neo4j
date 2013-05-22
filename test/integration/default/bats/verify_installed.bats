@test "neo4j is installed and running" {
  pid="$(cat /opt/neo4j/data/neo4j-service.pid)"
  result="$(sudo service neo4j-service status)"
   [ "$result" -eq "Neo4j Server is running at pid $pid" ]
}