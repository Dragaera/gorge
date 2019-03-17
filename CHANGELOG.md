# Change log

This document represents a high-level overview of changes made to this project.
It will not list every miniscule change, but will allow you to view - at a
glance - what to expact from upgrading to a new version.

## [unpublished]

### Added

### Changed

### Fixed

### Security

### Deprecated

### Removed


## [0.3.0] - 2019-03-17

### Added

- Caching of player statistics.
  This adds the ability to pre-calculate and store per-player statistics like
  KDR and accuracy. When queried, the API will then serve the most recent
  statistics, rather than calculating it on the fly.

  To accomodate multiple use-cases, various statistic classes can be defined,
  which influence the sample size to use for calculation of these statistics.

### Fixed

- Ensure data source updates are scheduled for the future, even if they were
  not processed in a long time.  This fixes cases where a data source - if it
  has not been processed for a long time - is scheduled according to its
  assigned update frequency, leading to a timestamp in the past, making it
  execute multiple times in succession.


## [0.2.2] - 2018-12-10

### Fixed

- Allow importing rounds where one or both starting locations are undefined or
  ill-defined. Will be stored as 'unknown' starting location.


## [0.2.1] - 2018-08-12

### Fixed

- Wrong sentry.io project in Makefile.


## [0.2.0] - 2018-08-12

### Added

- Importer: Store round lengths.
- Importer: Store map names.
- Importer: Store marine and alien starting locations.
- Importer: Store time spent per player for each class (lifeform, weapon, ...)
- Integration of sentry.io for excecption tracking.

### Changed

- Update ruby to `2.5.1`, update dependencies.

### Fixed

- Attempt to create `DataImport::STORAGE_PATH` if it doesn't exist yet.


## [0.1.1] - 2018-04-14

### Fixed

- Exceptions when calculating various player statistics, caused by dividing by zero:
  - `Player#kdr`, `Player#marine_kdr`, `Player#alien_kdr`: Zero deaths
  - `Player#accuracy`, `Player#marine_accuracy`, `Player#alien_accuracy`: Zero
    hits and misses
  - `Player#marine_accuracy(include_onos: false)`: Exclusively onos hits, and
    no misses
  - `Player#statistics`: All of the above.


## [0.1.0] - 2018-04-01

### Added

- Ingestion of NS2+-based Wonitor statistics
  - Per-player accuracy, KDR, ...

- HTTP-based API
  - Optional authentication

- Automatic downloads of NS2+ / Wonitor databases via HTTP

