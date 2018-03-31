# Gorge

This is the git repository of Gorge - an NS2+ / Wonitor stats aggregator.

It consumes NS2+ / Wonitor data from multiple sources, aggregates them, and
provides an API to query various statistics.

## Running

### Configuration

Configuration is done exclusively via environment variables. There are some
which need to be set for proper operation, but wherever possible, sane defaults
were used.

In the table below, `Required` indicates values you have to define, ie settings
which have no default, but are required for operation.

#### Database

| Setting       | Required | Default   | Description                                                          |
| ------------- | -------- | --------- | -------------------------------------------------------------------- |
| `DB_HOST`     | n        |           | Address of database server. Default is adapter-specific.             |
| `DB_PORT`     | n        |           | Port of database server. Default is adapter-specific.                |
| `DB_DATABASE` | y        |           | Name of database which to use.                                       |
| `DB_USER`     |          |           | User which to authenticate as. Default is adapter-specific.          |
| `DB_PASS`     |          |           | Password with which to authenticate as. Default is adapter-specific. |

#### Redis

| Setting      | Required | Default   | Description                                        |
| -------------| -------- | --------- | -------------------------------------------------- |
| `REDIS_HOST` | y        |           | Address of redis server.                           |
| `REDIS_PORT` | n        |           | Port of redis server. Default is adapter-specific. |

#### Resque

| Setting                     | Required | Default   | Description                                                         |
| --------------------------- | -------- | --------- | ------------------------------------------------------------------- |
| `RESQUE_WEB_PATH`           | n        |           | Subpath under which to make Resque GUI available. Empty to disable. |
| `RESQUE_DURATIONS_RECORDED` | n        | 10000     | Number of jobs to track for Resque job stats.                       |
| `INTERVAL`                  | n        |           | Inteval in seconds which worker waits between polling for jobs.     |
| `QUEUE`                     | y        |           | Queue from which worker pulls jobs. `*` to pull from all.           |


#### Data Import

| Setting                                | Required | Default   | Description                                                                                                       |
| -------------------------------------- | -------- | --------- | ----------------------------------------------------------------------------------------------------------------- |
| `DATA_IMPORT_STORAGE_PATH`             | y        |           | Directory in which downloaded data sources (ie sqlite DBs) are stored                                             |
| `DATA_IMPORT_HTTP_CONNECT_TIMEOUT`     | n        | 30        | Timeout in seconds for HTTP download of data sources.                                                             |
| `DATA_IMPORT_ERROR_THRESHOLD`          | n        | 5         | Number of failed download/processing attempts after which a data source will be disabled.                         |
| `DATA_IMPORT_DATA_FILE_RETENTION_TIME` | n        | 7d        | Number of seconds after which downloaded data sources are deleted from disk.                                      |
| `DATA_IMPORT_UPDATE_GRACE_PERIOD`      | n        | 4h        | Number of seconds after which pending data source downloads are assumed to have failed silently, and are retried. |

#### API

| Setting                     | Required | Default   | Description                                                                                    |
| --------------------------- | -------- | --------- | ---------------------------------------------------------------------------------------------- |
| `API_ENABLE_AUTHENTICATION` | n        | y         | Whether to enable HTTP basic authentication in front of the API. 'y', '1' or 'true' to enable. |
