/*
List all active users with their role assignment
*/

USE P21Play
GO

SELECT
  users.id,
  users.name,
  roles.role,
  users.date_created,
  users.date_last_modified,
  users.last_maintained_by,
  users.delete_flag
FROM users 
 INNER JOIN roles ON (roles.role_uid = users.role_uid)
WHERE
  (users.delete_flag = 'N')
ORDER BY
  roles.role