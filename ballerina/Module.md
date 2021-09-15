## Overview

This module provides the functionality that is required to access and manipulate data stored in any type of relational database,
which is accessible via Java Database Connectivity (JDBC).

### Prerequisite
Add the JDBC driver corresponding to the database you are trying to interact with
as a native library dependency in your Ballerina project's `Ballerina.toml` file.

Follow one of the following ways to add the corresponding database JAR in the file:

* Download the JAR and update the path
    ```
    [[platform.java11.dependency]]
    path = "PATH"
    ```

* Add JAR with a maven dependency params
    ```
    [[platform.java11.dependency]]
    artifactId = "h2"
    version = "1.4.200"
    groupId = "com.h2database"
    ```

### Client
To access a database, you must first create a
[jdbc:Client](https://docs.central.ballerina.io/ballerinax/java.jdbc/latest/clients/Client) object.
The samples for creating a JDBC client can be found below.

#### Creating a Client
This sample shows the different ways of creating the `jdbc:Client`. The client can be created by passing
the JDBC URL, which is a mandatory property and all other fields are optional.

The `dbClient` receives only the database URL.

E.g., The DB client creation for an H2 database will be as follows.
```ballerina
jdbc:Client|sql:Error dbClient = new ("jdbc:h2:~/path/to/database");
```

The `dbClient` receives the username and password in addition to the URL.
If the properties are passed in the same order as they are defined in the `jdbc:Client`, you can pass them
without named params.

E.g., The DB client creation for an H2 database will be as follows.
```ballerina
jdbc:Client|sql:Error dbClient = new ("jdbc:h2:~/path/to/database", 
                            "root", "root");
```

The `dbClient` uses the named params to pass all the attributes and provides the `options` property in the type of
[jdbc:Options](https://docs.central.ballerina.io/ballerinax/java.jdbc/latest/records/Options),
and also uses the unshared connection pool in the type of
[sql:ConnectionPool](https://docs.central.ballerina.io/ballerina/sql/latest/records/ConnectionPool).
For more information about connection pooling, see the [`sql` module](https://docs.central.ballerina.io/ballerina/sql/latest).

E.g., The DB client creation for an H2 database will be as follows.
```ballerina
jdbc:Client|sql:Error dbClient = new (url =  "jdbc:h2:~/path/to/database",
                             user = "root", password = "root",
                             options = {
                                 datasourceName: "org.h2.jdbcx.JdbcDataSource"
                             },
                             connectionPool = {
                                 maxOpenConnections: 5
                             });
```

The `dbClient` receives some custom properties within the
[jdbc:Options](https://docs.central.ballerina.io/ballerinax/java.jdbc/latest/records/Options),   
and those properties will be used by the defined `datasourceName`.
As per the provided sample, the `org.h2.jdbcx.JdbcDataSource` datasource  will be configured with a `loginTimeout`
of `2000` milliseconds.

E.g., The DB client creation for an H2 database will be as follows.
```ballerina
jdbc:Client|sql:Error dbClient = new (url =  "jdbc:h2:~/path/to/database", 
                             user = "root", password = "root",
                             options = {
                                datasourceName: "org.h2.jdbcx.JdbcDataSource", 
                                properties: {"loginTimeout": "2000"}
                             });                          
```

You can find more details about each property in the
[jdbc:Client](https://docs.central.ballerina.io/ballerinax/java.jdbc/latest/clients/Client) constructor.

The [jdbc:Client](https://docs.central.ballerina.io/ballerinax/java.jdbc/latest/clients/Client) references
[sql:Client](https://docs.central.ballerina.io/ballerina/sql/latest/clients/Client) and
all the operations defined by the `sql:Client` will be supported by the `jdbc:Client` as well.

#### Connection Pool Handling

All ballerina database modules share the same connection pooling concept and there are three possible scenarios for
connection pool handling.  For its properties and possible values, see the [`sql:ConnectionPool`](https://docs.central.ballerina.io/ballerina/sql/latest/records/ConnectionPool).

1. Global shareable default connection pool

   If you do not provide the `poolOptions` field when creating the database client, a globally-shareable pool will be
   created for your database unless a connection pool matching with the properties you provided already exists.
   The JDBC module sample below shows how the global connection pool is used.

   E.g., The DB client creation for an H2 database is as follows.
   ```ballerina
    jdbc:Client|sql:Error dbClient = 
                               new ("jdbc:h2:~/path/to/database", 
                                "root", "root");
    ```

2. Client owned, unsharable connection pool

   If you define the `connectionPool` field inline when creating the database client with the `sql:ConnectionPool` type,
   an unsharable connection pool will be created. The JDBC module sample below shows how the global
   connection pool is used.

   E.g., The DB client creation for an H2 database is as follows.
    ```ballerina
    jdbc:Client|sql:Error dbClient = 
                               new (url = "jdbc:h2:~/path/to/database", 
                               connectionPool = { maxOpenConnections: 5 });
    ```

3. Local, shareable connection pool

   If you create a record of type `sql:ConnectionPool` and reuse that in the configuration of multiple clients,
   for each set of clients that connects to the same database instance with the same set of properties, a shared
   connection pool will be created. The JDBC module sample below shows how the global connection pool is used.

   E.g., The DB client creation for an H2 database is as follows.
    ```ballerina
    sql:ConnectionPool connPool = {maxOpenConnections: 5};
    
    jdbc:Client|sql:Error dbClient1 =       
                               new (url = "jdbc:h2:~/path/to/database",
                               connectionPool = connPool);
    jdbc:Client|sql:Error dbClient2 = 
                               new (url = "jdbc:h2:~/path/to/database",
                               connectionPool = connPool);
    jdbc:Client|sql:Error dbClient3 = 
                               new (url = "jdbc:h2:~/path/to/database",
                               connectionPool = connPool);
    ```
   
#### Closing the Client

Once all the database operations are performed, you can close the database client you have created by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients. 

```ballerina
error? e = dbClient.close();
```
Or
```ballerina
check dbClient.close();
```

### Database Operations

Once the client is created, database operations can be executed through that client. This module defines the interface
and common properties that are shared among multiple database clients.  It also supports querying, inserting, deleting,
updating, and batch updating data.

#### Creating Tables

This sample creates a table with two columns. One column is of type `int` and the other is of type `varchar`.
The `CREATE` statement is executed via the `execute` remote function of the client.

```ballerina
// Create the ‘Students’ table with the  ‘id’, 'name', and ‘age’ fields.
sql:ExecutionResult result = check dbClient->execute("CREATE TABLE student(id INT AUTO_INCREMENT, " +
                         "age INT, name VARCHAR(255), PRIMARY KEY (id))");
//A value of the sql:ExecutionResult type is returned for 'result'. 
```

#### Inserting Data

These samples show the data insertion by executing an `INSERT` statement using the `execute` remote function
of the client.

In this sample, the query parameter values are passed directly into the query statement of the `execute`
remote function.

```ballerina
sql:ExecutionResult result = check dbClient->execute("INSERT INTO student(age, name) " +
                         "values (23, 'john')");
```

In this sample, the parameter values, which are in local variables are used to parameterize the SQL query in
the `execute` remote function. This type of parameterized SQL query can be used with any primitive Ballerina type
like `string`, `int`, `float`, or `boolean` and in that case, the corresponding SQL type of the parameter is derived
from the type of the Ballerina variable that is passed in.

```ballerina
string name = "Anne";
int age = 8;

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
```

In this sample, the parameter values are passed as a `sql:TypedValue` to the `execute` remote function. Use the
corresponding subtype of the `sql:TypedValue` such as `sql:Varchar`, `sql:Char`, `sql:Integer`, etc., when you need to
provide more details such as the exact SQL type of the parameter.

```ballerina
sql:VarcharValue name = new ("James");
sql:IntegerValue age = new (10);

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Inserting Data With Auto-generated Keys

This sample demonstrates inserting data while returning the auto-generated keys. It achieves this by using the
`execute` remote function to execute the `INSERT` statement.

```ballerina
int age = 31;
string name = "Kate";

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
//Number of rows affected by the execution of the query.
int? count = result.affectedRowCount;
//The integer or string generated by the database in response to a query execution.
string|int? generatedKey = result.lastInsertId;
}
```

#### Querying Data

These samples show how to demonstrate the different usages of the `query` operation and query the
database table and obtain the results.

The `sql:ParameterizedQuery` is used to construct the dynamic query to execute by the client. So, you can create a simple query like below.
```
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students WHERE id < ${id} AND age > ${age}`;
```

The `sql:queryConcat()` makes it easier to create a dynamic complex query by concatenating sub-dynamic queries.
The following sample shows how to concatenate queries:

```
int intType = 2147483647;
int bigIntType = 9223372036854774807;
int smallIntType = 32767;
sql:ParameterizedQuery query = `INSERT INTO NumericTypes (int_type, bigint_type, smallint_type)`;
sql:ParameterizedQuery query1 = ` VALUES(${intType},${bigIntType},${smallIntType})`;
sql:ParameterizedQuery sqlQuery = sql:queryConcat(query, query1);
```

Another util function is `arrayFlattenQuery()`, which accepts the array value and returns parameterized query.
So by using both functions, you can construct the complex dynamic query like below,

```
sql:VarcharValue stringValue1 = new("Hello");
sql:VarcharValue stringValue2 = new("1");
sql:VarcharValue[] values = [stringValue1, stringValue2];
sql:ParameterizedQuery sqlQuery = sql:queryConcat(`SELECT count(*) as total FROM DataTable WHERE string_type IN (`, sql:arrayFlattenQuery(values), `)`);
```

This sample demonstrates querying data from a table in a database.
First, a type is created to represent the returned result set. This record can be defined as an open or a closed record
according to the requirement. If an open record is defined, the returned stream type will include both defined fields
in the record and additional database columns fetched by the SQL query which are not defined in the record.
Note the mapping of the database column to the returned record's property is case-insensitive if it is defined in the
record(i.e., the `ID` column in the result can be mapped to the `id` property in the record). Additional Column names
added to the returned record as in the SQL query. If the record is defined as a close record, only defined fields in the
record are returned or gives an error when additional columns present in the SQL query. Next, the `SELECT` query is executed
via the `query` remote function of the client. Once the query is executed, each data record can be retrieved by looping
the result set. The `stream` returned by the select operation holds a pointer to the actual data in the database and it
loads data from the table only when it is accessed. This stream can be iterated only once.

```ballerina
// Define an open record type to represent the results.
type Student record {
    int id;
    int age;
    string name;
};

// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` samples, parameters can be passed as
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<Student, sql:Error?> resultStream = dbClient->query(query);

// Iterating the returned table.
error? e = resultStream.forEach(function(Student student) {
   //Can perform any operations using 'student' and can access any fields in the returned record of type Student.
});
```

Defining the return type is optional and you can query the database without providing the result type. Hence,
the above sample can be modified as follows with an open record type as the return type. The property name in the open record
type will be the same as how the column is defined in the database.

```ballerina
// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` samples, parameters can be passed as 
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<record{}, sql:Error?> resultStream = dbClient->query(query);

// Iterating the returned table.
error? e = resultStream.forEach(function(record{} student) {
    //Can perform any operations using the 'student' and can access any fields in the returned record.
    io:println("Student name: ", student.value["name"]);
});
```

There are situations in which you may not want to iterate through the database and in that case, you may decide
to only use the `next()` operation in the result `stream` and retrieve the first record. In such cases, the returned
result stream will not be closed and you have to explicitly invoke the `close` operation on the
`sql:Client` to release the connection resources and avoid a connection leak as shown below.

```ballerina
stream<record{}, sql:Error?> resultStream = 
            dbClient->query("SELECT count(*) as total FROM students");

record {|record {} value;|}? result = check resultStream.next();

if result is record {|record {} value;|} {
    // A valid result is returned.
    io:println("total students: ", result.value["total"]);
} else {
    // Student table must be empty.
}

error? e = resultStream.close();
```

#### Updating Data

This sample demonstrates modifying data by executing an `UPDATE` statement via the `execute` remote function of
the client.

```ballerina
int age = 23;
sql:ParameterizedQuery query = `UPDATE students SET name = 'John' 
                                WHERE age = ${age}`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Deleting Data

This sample demonstrates deleting data by executing a `DELETE` statement via the `execute` remote function of
the client.

```ballerina
string name = "John";
sql:ParameterizedQuery query = `DELETE from students WHERE name = ${name}`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Batch Updating Data

This sample demonstrates how to insert multiple records with a single `INSERT` statement that is executed via the
`batchExecute` remote function of the client. This is done by creating a `table` with multiple records and
parameterized SQL query as same as the  above `execute` operations.

```ballerina
// Create the table with the records that need to be inserted.
var data = [
  { name: "John", age: 25  },
  { name: "Peter", age: 24 },
  { name: "jane", age: 22 }
];

// Do the batch update by passing the batches.
sql:ParameterizedQuery[] batch = from var row in data
                                 select `INSERT INTO students ('name', 'age')
                                 VALUES (${row.name}, ${row.age})`;
sql:ExecutionResult[] result = check dbClient->batchExecute(batch);
```

#### Execute SQL Stored Procedures

This sample demonstrates how to execute a stored procedure with a single `INSERT` statement that is executed via the
`call` remote function of the client.

```ballerina
int uid = 10;
sql:IntegerOutParameter insertId = new;

sql:ProcedureCallResult|sql:Error result = dbClient->call(`call InsertPerson(${uid}, ${insertId})`);
if result is error {
    //An error returned
} else {
    stream<record{}, sql:Error?>? resultStr = result.queryResult;
    if resultStr is stream<record{}, sql:Error?> {
        sql:Error? e = resultStr.forEach(function(record{} result) {
        //can perform operations using 'result'.
      });
    }
    check result.close();
}
```
Note that you have to explicitly invoke the close operation on the `sql:ProcedureCallResult` to release the connection resources and avoid a connection leak as shown above.

>**Note:** The default thread pool size used in Ballerina is: `the number of processors available * 2`. You can configure the thread pool size by using the `BALLERINA_MAX_POOL_SIZE` environment variable.
