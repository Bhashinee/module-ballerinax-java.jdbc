## Overview

This module provides the functionality required to access and manipulate data stored in any type of relational database
that is accessible via Java Database Connectivity (JDBC).

**Prerequisite:** Add the JDBC driver corresponding to the database you are trying to interact with
as a native library dependency in your Ballerina project. Then, once you build the project by executing the `ballerina build`
command, you should be able to run the resultant by executing the `ballerina run` command.

E.g., The `Ballerina.toml` content for h2 database.
Change the path to the JDBC driver appropriately.

```toml
[package]
org = "sample"
name = "jdbc"
version= "0.1.0"

[[platform.java11.dependency]]
artifactId = "h2"
version = "1.4.200"
path = "/path/to/com.h2database.h2-1.4.200.jar"
groupId = "com.h2database"
``` 

### Client
To access a database, you must first create a
[jdbc:Client](https://ballerina.io/learn/api-docs/ballerina/#/java.jdbc/clients/Client) object.
The examples for creating a JDBC client can be found below.

#### Creating a Client
This example shows the different ways of creating the `jdbc:Client`. The client can be created by passing
the JDBC URL, which is a mandatory property and all other fields are optional.

The `dbClient` receives only the database URL.

E.g., db client creation for h2 database.
```ballerina
jdbc:Client|sql:Error dbClient = new ("jdbc:h2:~/path/to/database");
```

The `dbClient` receives the username and password in addition to the URL.
If the properties are passed in the same order as it is defined in the `jdbc:Client`, you can pass it
without named params.

E.g., db client creation for h2 database.
```ballerina
jdbc:Client|sql:Error dbClient = new ("jdbc:h2:~/path/to/database", 
                            "root", "root");
```



The `dbClient` uses the named params to pass all the attributes and provides the `options` property in the type of
[jdbc:Options](https://ballerina.io/learn/api-docs/ballerina/#/java.jdbc/records/Options)
and also uses the unshared connection pool in the type of
[sql:ConnectionPool](https://ballerina.io/learn/api-docs/ballerina/#/sql/records/ConnectionPool).
For more information about connection pooling, see [SQL Module](https://ballerina.io/learn/api-docs/ballerina/#/sql).

E.g., db client creation for h2 database.
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
[jdbc:Options](https://ballerina.io/learn/api-docs/ballerina/#/java.jdbc/records/Options)
and those properties will be used by the defined `datasourceName`.
As per the provided example, the `org.h2.jdbcx.JdbcDataSource` datasource  will be configured with a `loginTimeout`
of `2000` milliseconds.

E.g., db client creation for h2 database.
```ballerina
jdbc:Client|sql:Error dbClient = new (url =  "jdbc:h2:~/path/to/database", 
                             user = "root", password = "root",
                             options = {
                                datasourceName: "org.h2.jdbcx.JdbcDataSource", 
                                properties: {"loginTimeout": "2000"}
                             });                          
```

You can find more details about each property in the
[jdbc:Client](https://ballerina.io/learn/api-docs/ballerina/#/java.jdbc/clients/Client) constructor.

The [jdbc:Client](https://ballerina.io/learn/api-docs/ballerina/#/java.jdbc/clients/Client) references
[sql:Client](https://ballerina.io/learn/api-docs/ballerina/#/sql/abstractObjects/Client) and
all the operations defined by the `sql:Client` will be supported by the `jdbc:Client` as well.

#### Connection Pool Handling

All ballerina database modules share the same connection pooling concept and there are 3 possible scenarios for
connection pool handling.  For its properties and possible values, see the `sql:ConnectionPool`.

1. Global shareable default connection pool

   If you do not provide the `poolOptions` field when creating the database client, a globally-shareable pool will be
   created for your database unless a connection pool matching with the properties you provided already exists.
   The JDBC module example below shows how the global connection pool is used.

   E.g., db client creation for h2 database.
   ```ballerina
    jdbc:Client|sql:Error dbClient = 
                               new ("jdbc:h2:~/path/to/database", 
                                "root", "root");
    ```

2. Client owned, unsharable connection pool

   If you define the `connectionPool` field inline when creating the database client with the `sql:ConnectionPool` type,
   an unsharable connection pool will be created. The JDBC module example below shows how the global
   connection pool is used.

   E.g., db client creation for h2 database.
    ```ballerina
    jdbc:Client|sql:Error dbClient = 
                               new (url = "jdbc:h2:~/path/to/database", 
                               connectionPool = { maxOpenConnections: 5 });
    ```

3. Local, shareable connection pool

   If you create a record of type `sql:ConnectionPool` and reuse that in the configuration of multiple clients,
   for each  set of clients that connects to the same database instance with the same set of properties, a shared
   connection pool will be created. The JDBC module example below shows how the global connection pool is used.

   E.g., db client creation for h2 database.
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
The CREATE statement is executed via the `execute` remote function of the client.

```ballerina
// Create the ‘Students’ table with the  ‘id’, 'name' and ‘age’ fields.
sql:ExecutionResult ret = check dbClient->execute("CREATE TABLE student(id INT AUTO_INCREMENT, " +
                         "age INT, name VARCHAR(255), PRIMARY KEY (id))");
//A value of type sql:ExecutionResult is returned for 'ret'. 
```

#### Inserting Data

This sample shows three examples of data insertion by executing an INSERT statement using the `execute` remote function
of the client.

In the first example, the query parameter values are passed directly into the query statement of the `execute`
remote function.

```ballerina
sql:ExecutionResult ret = check dbClient->execute("INSERT INTO student(age, name) " +
                         "values (23, 'john')");
```

In the second example, the parameter values, which are in local variables are used to parameterize the SQL query in
the `execute` remote function. This type of parameterized SQL query can be used with any primitive Ballerina type
like `string`, `int`, `float`, or `boolean` and in that case, the corresponding SQL type of the parameter is derived
from the type of the Ballerina variable that is passed in.

```ballerina
string name = "Anne";
int age = 8;

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResult ret = check dbClient->execute(query);
```

In the third example, the parameter values are passed as a `sql:TypedValue` to the `execute` remote function. Use the
corresponding subtype of the `sql:TypedValue` such as `sql:Varchar`, `sql:Char`, `sql:Integer`, etc, when you need to
provide more details such as the exact SQL type of the parameter.

```ballerina
sql:VarcharValue name = new ("James");
sql:IntegerValue age = new (10);

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResult ret = check dbClient->execute(query);
```

#### Inserting Data With Auto-generated Keys

This example demonstrates inserting data while returning the auto-generated keys. It achieves this by using the
`execute` remote function to execute the INSERT statement.

```ballerina
int age = 31;
string name = "Kate";

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResultret = check dbClient->execute(query);
//Number of rows affected by the execution of the query.
int? count = ret.affectedRowCount;
//The integer or string generated by the database in response to a query execution.
string|int? generatedKey = ret.lastInsertId;
}
```

#### Querying Data

This sample shows three examples to demonstrate the different usages of the `query` operation and query the
database table and obtain the results.

This example demonstrates querying data from a table in a database.
First, a type is created to represent the returned result set. Note the mapping of the database column
to the returned record's property is case-insensitive (i.e., `ID` column in the result can be mapped to the `id`
property in the record). Next, the SELECT query is executed via the `query` remote function of the client by passing that
result set type. Once the query is executed, each data record can be retrieved by looping the result set. The `stream`
returned by the select operation holds a pointer to the actual data in the database and it loads data from the table
only when it is accessed. This stream can be iterated only once.

```ballerina
// Define a type to represent the results.
type Student record {
    int id;
    int age;
    string name;
};

// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` examples, parameters can be passed as
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<Student, sql:Error> resultStream = 
        <stream<Student, sql:Error>> dbClient->query(query, Student);

// Iterating the returned table.
error? e = resultStream.forEach(function(Student student) {
   //Can perform any operations using 'student' and can access any fields in the returned record of type Student.
});
```

Defining the return type is optional, and you can query the database without providing the result type. Hence,
the above example can be modified as follows with an open record type as the return type. The property name in the open record
type will be the same as how the column is defined in the database.

```ballerina
// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` examples, parameters can be passed as 
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<record{}, sql:Error> resultStream = dbClient->query(query);

// Iterating the returned table.
error? e = resultStream.forEach(function(record{} student) {
    //Can perform any operations using 'student' and can access any fields in the returned record.
});
```

There are situations in which you may not want to iterate through the database and in that case, you may decide
to only use the `next()` operation in the result `stream` and retrieve the first record. In such cases, the returned
result stream will not be closed, and you have to explicitly invoke the `close` operation on the
`sql:Client` to release the connection resources and avoid a connection leak as shown below.

```ballerina
stream<record{}, sql:Error> resultStream = 
            dbClient->query("SELECT count(*) as total FROM students");

record {|record {} value;|}|error? result = resultStream.next();

if result is record {|record {} value;|} {
    //valid result is returned.
} else if result is error {
    // An error is returned as the result.
} else {
    // Student table must be empty.
}

error? e = resultStream.close();
```

#### Updating Data

This example demonstrates modifying data by executing an UPDATE statement via the `execute` remote function of
the client.

```ballerina
int age = 23;
sql:ParameterizedQuery query = `UPDATE students SET name = 'John' 
                                WHERE age = ${age}`;
sql:ExecutionResult|sql:Error ret = check dbClient->execute(query);
```

#### Deleting Data

This example demonstrates deleting data by executing a DELETE statement via the `execute` remote function of
the client.

```ballerina
string name = "John";
sql:ParameterizedQuery query = `DELETE from students WHERE name = ${name}`;
sql:ExecutionResult|sql:Error ret = check dbClient->execute(query);
```

#### Batch Updating Data

This example demonstrates how to insert multiple records with a single INSERT statement that is executed via the
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
sql:ExecutionResult[] ret = check dbClient->batchExecute(batch);
```

#### Execute SQL Stored Procedures

This example demonstrates how to execute a stored procedure with a single INSERT statement that is executed via the
`call` remote function of the client.

```ballerina
int uid = 10;
sql:IntegerOutParameter insertId = new;

sql:ProcedureCallResult|sql:Error ret = dbClient->call(`call InsertPerson(${uid}, ${insertId})`);
if ret is error {
    //An error returned
} else {
    stream<record{}, sql:Error>? resultStr = ret.queryResult;
    if resultStr is stream<record{}, sql:Error> {
        sql:Error? e = resultStr.forEach(function(record{} result) {
        //can perform operations using 'result'.
      });
    }
    check ret.close();
}
```
Note that you have to explicitly invoke the close operation on the `sql:ProcedureCallResult` to release the connection resources and avoid a connection leak as shown above.

>**Note:** The default thread pool size used in Ballerina is the number of processors available * 2. You can configure
the thread pool size by using the `BALLERINA_MAX_POOL_SIZE` environment variable.
