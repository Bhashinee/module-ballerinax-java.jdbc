// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/sql;

string xaDatasourceName = "org.h2.jdbcx.JdbcDataSource";

string xaTransactionDB1 = "jdbc:h2:" + dbPath + "/" + "XA_TRANSACTION_1";
string xaTransactionDB2 = "jdbc:h2:" + dbPath + "/" + "XA_TRANSACTION_2";

@test:BeforeGroups {
    value: ["xa-transaction"]
}
isolated function initXATransactionDB() {
    initializeDatabase("XA_TRANSACTION_1", "transaction", "xa-transaction-test-data-1.sql");
    initializeDatabase("XA_TRANSACTION_2", "transaction", "xa-transaction-test-data-2.sql");
}

type XAResultCount record {
    int COUNTVAL;
};

@test:Config {
    groups: ["transaction", "xa-transaction"]
}
function testXATransactionSuccess() {
    Client dbClient1 = checkpanic new (url = xaTransactionDB1, user = user, password = password,
    connectionPool = {maxOpenConnections: 1});
    Client dbClient2 = checkpanic new (url = xaTransactionDB2, user = user, password = password,
    connectionPool = {maxOpenConnections: 1});

    transaction {
        var e1 = checkpanic dbClient1->execute("insert into Customers (customerId, name, creditLimit, country) " +
                                "values (1, 'Anne', 1000, 'UK')");
        var e2 = checkpanic dbClient2->execute("insert into Salary (id, value ) values (1, 1000)");
        checkpanic commit;
    }

    int count1 = checkpanic getCustomerCount(dbClient1, "1");
    int count2 = checkpanic getSalaryCount(dbClient2, "1");
    test:assertEquals(count1, 1, "First transaction failed"); 
    test:assertEquals(count2, 1, "Second transaction failed"); 

    checkpanic dbClient1.close();
    checkpanic dbClient2.close();
}

@test:Config {
    groups: ["transaction", "xa-transaction"]
}
function testXATransactionSuccessWithDataSource() {
    Client dbClient1 = checkpanic new (url = xaTransactionDB1, user = user, password = password,
    options = {datasourceName: xaDatasourceName});
    Client dbClient2 = checkpanic new (url = xaTransactionDB2, user = user, password = password,
    options = {datasourceName: xaDatasourceName});
    
    transaction {
        var e1 = checkpanic dbClient1->execute("insert into Customers (customerId, name, creditLimit, country) " +
                                "values (10, 'Anne', 1000, 'UK')");
        var e2 = checkpanic dbClient2->execute("insert into Salary (id, value ) values (10, 1000)");
        checkpanic commit;
    }
    
    int count1 = checkpanic getCustomerCount(dbClient1, "10");
    int count2 = checkpanic getSalaryCount(dbClient2, "10");
    test:assertEquals(count1, 1, "First transaction failed"); 
    test:assertEquals(count2, 1, "Second transaction failed"); 

    checkpanic dbClient1.close();
    checkpanic dbClient2.close();
}

isolated function getCustomerCount(Client dbClient, string id) returns int|error{
    stream<XAResultCount, sql:Error?> streamData = <stream<XAResultCount,  sql:Error?>> dbClient->query("Select COUNT(*) as " +
        "countval from Customers where customerId = "+ id, XAResultCount);
    return getResult(streamData);
}

isolated function getSalaryCount(Client dbClient, string id) returns int|error{
    stream<XAResultCount,  sql:Error?> streamData =
    <stream<XAResultCount,  sql:Error?>> dbClient->query("Select COUNT(*) as countval " +
    "from Salary where id = "+ id, XAResultCount);
    return getResult(streamData);
}

isolated function getResult(stream<XAResultCount,  sql:Error?> streamData) returns int{
    record {|XAResultCount value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    XAResultCount? value = data?.value;
    if(value is XAResultCount){
       return value.COUNTVAL;
    }
    return 0;
}
