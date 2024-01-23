/*
Atlas Precision Consulting LLC - 1/23/2024
By: Andrew Podner

List all active users with their role assignment

This script and any associated comments are a good faith attempt to
assist the consumer with their environment.  No warranty is expressed
or implied.   Consumer uses this script at his/her own risk.

!!!! Test all code in a Play / Pre-Production Environment before running
against the live database!!!!!


*/

SELECT
  users.id,
  users.name,
  roles.role,
  users.date_created,
  users.date_last_modified,
  users.last_maintained_by,
  users.delete_flag,
  users.contact_id as buyer_id,
  users.default_salesrep_on_order,
  users.default_company,
  users.default_branch,
  users.default_location_id
FROM users 
 INNER JOIN roles ON (roles.role_uid = users.role_uid)
WHERE
  users.delete_flag <> 'Y'
  and roles.delete_flag <> 'Y'
ORDER BY
  roles.role, users.id
