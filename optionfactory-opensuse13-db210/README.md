this docker image needs a data volume (db2 uses O_DIRECT access, not supported by aufs).

To create a data-only image: 

# docker run --name=db2_data --label=data=true -v /home/db2inst1/ busybox true

To start db2 using the data-only image:

# docker run -ti --privileged -p 50000:50000 --volumes-from=db2_data optionfactory/opensuse13-db210

To test the image:

# docker exec -ti db2-container-name /bin/bash
  # db2 connect to test
  # db2 list tables for all
# docker exec -ti -u dasusr1 db2-container-name /bin/bash
  # db2 connect to test
  # db2 list tables