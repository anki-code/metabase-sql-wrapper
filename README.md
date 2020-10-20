<p align="center">
<b>metabase-sql-wrapper</b> is a docker-container based on Metabase container<br> that automatically saves Metabase H2 database
to SQL-file (on stop)<br> and creates Metabase H2 database from SQL-file (on start if the database doesn't exists). 
</p>

<p align="center">
This allows to save the Metabase H2 database SQL-file to Git, versioning changes<br> and restore the database from SQL-file.
</p>

<p align="center">
If you like the idea click ⭐ on the repo and stay tuned.
</p>

## Run container
```shell script
git clone https://github.com/anki-code/metabase-sql-wrapper
cd metabase-sql-wrapper
docker-compose up
```

## How it works

1. `docker-compose.yml` file has environment variables:

    ```shell script
    MB_DB_FILE: /data/metabase
    MB_DB_INIT_SQL_FILE: /data/metabase.db.sql     # (optional) used to build the DB if MB_DB_FILE doesn't exists 
    MB_DB_SAVE_TO_SQL_FILE: /data/metabase.db.sql  # (optional) used to save SQL when container was stopped
    ```

2. `docker-compose up` runs `run.xsh` with [xonsh shell](https://xon.sh/contents.html) wrapper that catches 
the docker signals and environment variables and do saving or creating the Metabase DB after stopping 
or before starting the container.

3. If `MB_DB_INIT_SQL_FILE` is set and `MB_DB_FILE` directory doesn't exists then before running Metabse 
the database will be created from the SQL-file.

4. If `MB_DB_SAVE_TO_SQL_FILE` is set and the container will get stop/restart signal then the database will be saved 
to SQL-file after Metabase has been stopped.

This way you can run container, save your queries to Metabase, stop the container and commit it to Git.

## Cleaning the database before commit to Git

By default Metabase writes logs and history to the database. To clean this before commit to Git you can 
use the `metabase-db-clean.sql` script:
```bash
java -cp metabase.jar org.h2.tools.RunScript -url jdbc:h2:./metabase.db -script /path/to/repository/metabase-db-clean.sql
```

## Links

* This container based on [docker-xonsh-wrapper](https://github.com/anki-code/docker-xonsh-wrapper)
