# Performing a switchover

In this lab we will Performing a gracefull switchover.


> **Warning** on copying and pasting commands with multiple lines from the browser screen; when you copy from outside of the Remote Desktop environment and paste inside the Remote Desktop environment, additional **enters** or CRLF characters are pasted causing some commands to fail. 


## Performing a switchover

A switchover is always started from the primary database, where a failover is initiated from the standby database. 
The difference between a switchover and a failover is that a switchover is a graceful operation where a failover is only needed when the primary database is broken beyond repair or that repair would take too long. 

We will use SQL Developer to connect to the Database System.You can run this tool from any desktop that has network connectivity to the Database System.

You can download SQL Developer from this link: [SQL Developer Home page](https://www.oracle.com/be/database/technologies/appdev/sqldeveloper-landing.html) 

Please make sure to complete Lab 3 before starting this Lab.


## Verify the database roles in the database

Using SQL Developer, you can drag and drop the panes so that they are next to eachother or shown split horizontally. 

![](./images/Switchover_01.png)


Verify the roles with following Query:

````
Select name, db_unique_name, database_role from v$database;
````

Enter this query in both panes and click the run button to see the result.

![](./images/Switchover_02.png)

We can conclude that the Database in AD1 is the primary database and the database in AD2 is the Standby database.


## Perform the role transition

In the OCI console, navigate to the DB System Details of the ADGHOLAD1 database and scroll down to the Databases section.

Overview
-> Bare Metal, VM and Exadata
-> DB Systems

Select **ADGHOLAD1**
![](./images/Switchover_03.png)

Click on the name **DGHOL** and in the next screen scroll down immediately and click on **Data Guard Associations**

![](./images/Switchover_04.png)

Click on the 3 dots on the right, and click **Switchover**
![](./images/Switchover_05.png)

This is a DBA responsability, so the tooling asks the password. Enter the SYS password from the Primary database and click **OK** then the role transition starts.
![](./images/Switchover_06.png)

At this point, the lifecycle state will be updating and the role transition happens in the background.
![](./images/Switchover_07.png)

After some time the role transition finished and the state is Available again. 
![](./images/Switchover_08.png)


## Verify the database roles in the database

Using SQL Developer, verify the roles again with following Query:

````
Select name, db_unique_name, database_role from v$database;
````

Enter this query in both panes and click the run button to see the result.

![](./images/Switchover_09.png)

We can conclude that the Database in AD2 is the primary database and the database in AD1 is the Standby database.


## Summary
You have now succesfully performed a gracefull role transition.