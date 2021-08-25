# Changelog
This file contains all the notable changes done to the Ballerina java.jdbc package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- [Add completion type as nil in SQL query return stream type](https://github.com/ballerina-platform/ballerina-standard-library/issues/1654)

### Added
- [Add support for queryRow](https://github.com/ballerina-platform/ballerina-standard-library/issues/1604)
- [Add support for configuring the retrieval of auto generated keys on query execution](https://github.com/ballerina-platform/ballerina-standard-library/issues/1804)

## [0.6.0-beta.2] - 2021-06-22

### Changed
- [Change default rowType of the query remote method from `nil` to `<>`](https://github.com/ballerina-platform/ballerina-standard-library/issues/1445)

## [0.6.0-beta.1] - 2021-06-02

### Changed
- Make JDBC Client class isolated