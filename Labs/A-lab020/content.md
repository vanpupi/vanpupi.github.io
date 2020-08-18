# Setup Autonomous Data Guard 19c 

In this lab we will setup 19c Data Guard between a primary server and a secondary server. 

This Lab assumes that there are 2 identical servers available. For example the 19c Database Market place image from the OCI. 



> **Warning** on copying and pasting commands with multiple lines from the browser screen; when you copy from outside of the Remote Desktop environment and paste inside the Remote Desktop environment, additional **enters** or CRLF characters are pasted causing some commands to fail. Solution: Open this lab inside the browser inside the Remote Desktop session.

## Disclaimer ##
The following is intended to outline our general product direction. It is intended for information purposes only, and may not be incorporated into any contract. It is not a commitment to deliver any material, code, or functionality, and should not be relied upon in making purchasing decisions. The development, release, and timing of any features or functionality described for Oracle’s products remains at the sole discretion of Oracle.

## Setup the ADB-S Database

To Create an autonomous database the command is pretty simple:


````
$ oci db autonomous-database create --compartment-id ${COMPARTMENT_ID} --db-name adbscli19c --cpu-core-count 1 --data-storage-size-in-tbs 1 --admin-password ${PASSWORD} --db-version 19c
````

Don’t forget to make sure to specify a 19c version. At the date of publication, the default is still 18c and Autonomous Data Guard is not available there. It gives you back a Json with all the info:

````
$ oci db autonomous-database create --compartment-id ${COMPARTMENT_ID} --db-name adbscli19c --cpu-core-count 1 --data-storage-size-in-tbs 1 --admin-password ${PASSWORD} --db-version 19c
{
  "data": {
    "autonomous-container-database-id": null,
    "available-upgrade-versions": null,
    "compartment-id": "ocid1.compartment.oc1..aaa***ulq",
    "connection-strings": {
      "all-connection-strings": null,
      "dedicated": null,
      "high": null,
      "low": null,
      "medium": null
    },
    "connection-urls": {
      "apex-url": null,
      "machine-learning-user-management-url": null,
      "sql-dev-web-url": null
    },
    "cpu-core-count": 1,
    "data-safe-status": "NOT_REGISTERED",
    "data-storage-size-in-tbs": 1,
    "db-name": "adbscli19c",
    "db-version": "19c",
    "db-workload": "OLTP",
    "defined-tags": {},
    "display-name": "autonomousdatabase20200716145953",
    "failed-data-recovery-in-seconds": null,
    "freeform-tags": {},
    "id": "ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abth***sq",
    "infrastructure-type": null,
    "is-auto-scaling-enabled": false,
    "is-data-guard-enabled": false,
    "is-dedicated": false,
    "is-free-tier": false,
    "is-preview": false,
    "license-model": "BRING_YOUR_OWN_LICENSE",
    "lifecycle-details": null,
    "lifecycle-state": "PROVISIONING",
    "nsg-ids": null,
    "private-endpoint": null,
    "private-endpoint-ip": null,
    "private-endpoint-label": null,
    "service-console-url": null,
    "standby-db": null,
    "subnet-id": null,
    "system-tags": {},
    "time-created": "2020-07-16T14:59:53.410000+00:00",
    "time-deletion-of-free-autonomous-database": null,
    "time-maintenance-begin": null,
    "time-maintenance-end": null,
    "time-of-last-failover": null,
    "time-of-last-switchover": null,
    "time-reclamation-of-free-autonomous-database": null,
    "used-data-storage-size-in-tbs": null,
    "whitelisted-ips": null
  },
  "etag": "9d4539bd",
  "opc-work-request-id": "ocid1.coreservicesworkrequest.oc1.eu-frankfurt-1.abt***ec6q"
}
$
````

And of course this good friend is also quickly created


But we can check it with OCI too:

````
$  oci db autonomous-database list --db-version 19c --compartment-id ${COMPARTMENT_ID}| jq '.data&#91;]'| jq -c  '&#91;."db-name", .id, ."lifecycle-state"]'
&#91;"pvanpuym","ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abt****6zipq","TERMINATED"]
&#91;"adbscli19c","ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abt***bpsq","AVAILABLE"]
$
````
## Enable Autonomous Data Guard ##

I have then stored the OCID from the new pvanpuymcli database in my ADBID variable and to enable it for Autonomous Data Guard you just issue following command

````
oci db autonomous-database update --autonomous-database-id ${ADBID} --is-data-guard-enabled true
````

Then it returns a lot of Json again to inform you

````
$ oci db autonomous-database update --autonomous-database-id ${ADBID} --is-data-guard-enabled true
{
  "data": {
    "autonomous-container-database-id": null,
    "available-upgrade-versions": &#91;],
    "compartment-id": "ocid1.compartment.oc1..aa***lq",
    "connection-strings": {
...     
 Output omitted
...
    "cpu-core-count": 1,
    "data-safe-status": "NOT_REGISTERED",
    "data-storage-size-in-tbs": 1,
    "db-name": "adbscli19c",
    "db-version": "19c",
    "db-workload": "OLTP",
    "defined-tags": {},
    "display-name": "autonomousdatabase20200716145953",
    "failed-data-recovery-in-seconds": null,
    "freeform-tags": {},
    "id": "ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abth***sq",
    "infrastructure-type": null,
    "is-auto-scaling-enabled": false,
    "is-data-guard-enabled": false,
    "is-dedicated": false,
    "is-free-tier": false,
    "is-preview": false,
    "license-model": "BRING_YOUR_OWN_LICENSE",
    "lifecycle-details": null,
    "lifecycle-state": "UPDATING",
    "nsg-ids": null,
    "private-endpoint": null,
    "private-endpoint-ip": null,
    "private-endpoint-label": null,
    "service-console-url": "https://adb.eu-frankfurt-1.oraclecloud.com/console/index.html?tenant_name=OCID1.TENANCY.OC1..AAAA***JO2EA&amp;database_name=adbscli19c&amp;service_type=ATP",
    "standby-db": {
      "lag-time-in-seconds": null,
      "lifecycle-details": null,
      "lifecycle-state": "PROVISIONING"
    },
    "subnet-id": null,
    "system-tags": {},
    "time-created": "2020-07-16T14:59:53.410000+00:00",
    "time-deletion-of-free-autonomous-database": null,
    "time-maintenance-begin": "2020-07-18T08:00:00+00:00",
    "time-maintenance-end": "2020-07-18T14:30:00+00:00",
    "time-of-last-failover": null,
    "time-of-last-switchover": null,
    "time-reclamation-of-free-autonomous-database": null,
    "used-data-storage-size-in-tbs": null,
    "whitelisted-ips": null
  },
  "etag": "93d65ef0",
  "opc-work-request-id": "ocid1.coreservicesworkrequest.oc1.eu-frankfurt-1.abtheljrrdeqourqmtglrnmp3wz5q4qvepnszen5c3ak64y3z6n77xqqriya"
}
$
````

And afterwards you see it starts provisioning again, just as the GUI did in the previous lesson. When all is done, it is just as if you did it via GUI.
