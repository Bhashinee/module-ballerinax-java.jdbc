Ballerina JDBC library
===================

  [![Build](https://github.com/ballerina-platform/module-ballerina-java.jdbc/workflows/Build/badge.svg)](https://github.com/ballerina-platform/module-ballerina-java.jdbc/actions?query=workflow%3ABuild)
  [![GitHub Release](https://img.shields.io/github/release/ballerina-platform/module-ballerina-java.jdbc.svg)](https://central.ballerina.io/ballerina/java.jdbc)
  [![GitHub Release Date](https://img.shields.io/github/release-date/ballerina-platform/module-ballerina-java.jdbc.svg)](https://central.ballerina.io/ballerina/java.jdbc)
  [![GitHub Open Issues](https://img.shields.io/github/issues-raw/ballerina-platform/module-ballerina-java.jdbc.svg)](https://github.com/ballerina-platform/module-ballerina-java.jdbc/issues)
  [![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerina-java.jdbc.svg)](https://github.com/ballerina-platform/module-ballerina-java.jdbc/commits/master)
  [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

JDBC Driver for <a target="_blank" href="https://ballerina.io/">Ballerina</a> language.

For more information on all the operations supported by the `jdbc:Client`, which includes the below mentioned operations, see [API Docs](https://ballerina.io/swan-lake/learn/api-docs/ballerina/java.jdbc/).

1. Connection Pooling
1. Querying data
1. Inserting data
1. Updating data
1. Deleting data
1. Batch insert and update data
1. Execute stored procedures
1. Closing client

For a quick sample on demonstrating the usage see [Ballerina By Example](https://ballerina.io/swan-lake/learn/by-example/)

## Building from the source

1. To build the JDBC library use, issue the following command.
        
        ./gradlew clean build

2. To run the integration tests

        ./gradlew clean test

3. To build the module without tests,

        ./gradlew clean build -x test

4. To run only specific tests,

        ./gradlew clean build -Pgroups=<Comma separated groups/test cases>

   The following groups of test cases are available,<br>
   Groups | Test Cases
   ---| ---
   connection | connection
   pool | pool
   transaction | local-transaction <br> xa-transaction
   execute | execute-basic <br> execute-params
   batch-execute | batch-execute 
   query | query-simple-params<br>query-numerical-params<br>query-complex-params

5. To debug the tests,

        ./gradlew clean build -Pdebug=<port>

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. To start contributing, read these [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md) for information on how you should go about contributing to our project.

Check the issue tracker for open issues that interest you. We look forward to receiving your contributions.

## Useful links

* The ballerina-dev@googlegroups.com mailing list is for discussing code changes to the Ballerina project.
* Chat live with us on our [Slack channel](https://ballerina.io/community/slack/).
* Technical questions should be posted on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
* Ballerina performance test results are available [here](performance/benchmarks/summary.md).
