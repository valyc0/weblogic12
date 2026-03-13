mkdir -p "$(pwd)/domain-data"
chmod -R 777 "$(pwd)/domain-data"

docker run -d \
  --name weblogic12 \
  -p 7001:7001 \
  -p 7002:7002 \
  -p 9002:9002 \
  -v "$(pwd)/domain.properties":/u01/oracle/properties/domain.properties \
  -v "$(pwd)/domain-data":/u01/oracle/user_projects/domains \
  augusjin/oracle-weblogic:12.2.1.4-generic
