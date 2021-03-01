# Change The passwords

In this lab we will use the cloud interface to change the passwords.

In a cloud environment it is important to use the provided cloud tooling as much as possible. It is possible to maintain your own passwords, however this can break the automation in the cloud interface. 

This lab will show on how to correctly change the SYS password in a Data Guard environment.

Doing this right is important. When you change the SYS password in a Data Guard environment, Data Guard will propagate password changes for the SYS user to the standby database.


> **Warning** on copying and pasting commands with multiple lines from the browser screen; when you copy from outside of the Remote Desktop environment and paste inside the Remote Desktop environment, additional **enters** or CRLF characters are pasted causing some commands to fail. 

## Change the SYS password

Navigate to the HOLDG primary database following 

Overview
-> Bare Metal, VM and Exadata
-> DB Systems (choose ADGHOLAD1)
-> DB System Details

At the bottom click on the HOLDG database.

![](./images/SYS_01.png)

Find the drop down wich lists **More Actions** and click on **Manage Passwords**.

![](./images/SYS_02.png)

Enter the new SYS password. Keep in mind that the Password must be 9 to 30 characters and contain at least 2 uppercase, 2 lowercase, 2 special, and 2 numeric characters. The special characters must be _, #, or -.

As the password for this lab, use: **WelC0me1##**

And click **Apply**

![](./images/SYS_03.png)

## Verify 

Using SQL Developer, try to log in to the database as the SYS user. This will fail if you previously stored the password. The tool prompts you for the new password. 

![](./images/SYS_04.png)

When you specify the new password, the connection succeeds.

![](./images/SYS_05.png)


## Summary
You have now succesfully changed the SYS password.