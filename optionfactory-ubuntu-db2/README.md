this docker image needs a data volume (db2 uses O_DIRECT access, not supported by aufs).

To create a data-only image: 

# docker run --name=db2_data -v /home busybox true

To initialize the db (in the data container):

# docker run -u root --volumes-from=db2_data optionfactory/ubuntu-db2 init

To start db2 using the data-only image:

# docker run --privileged -p 50000:50000 --volumes-from=db2_data optionfactory/ubuntu-db2