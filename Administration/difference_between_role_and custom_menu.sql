/**
This SQL script returns a data set that allows you to compare the 
difference between a user's custom menu and their role's menu.
*/
USE P21Play
GO

SELECT
    c.custom_objects_uid
    ,users_id
	  ,u.name
    ,c.date_last_modified
	  ,r.role
    ,version_id
    ,version_desc
	  ,d.object_name
	  ,d.attribute_value as user_custom_menu_value
	  ,ro.attribute_value as role_menu_value
FROM dbo.custom_objects c
  INNER JOIN
    dbo.users u on c.users_id = u.id
	INNER JOIN
	  dbo.roles r on u.role_uid = r.role_uid
	LEFT JOIN
	  dbo.custom_objects_detail d on c.custom_objects_uid = d.custom_objects_uid
	LEFT JOIN (
		SELECT
			h.role_id
			,d.object_name
			,d.attribute_value
		FROM
			dbo.custom_objects h
				INNER JOIN dbo.custom_objects_detail d on h.custom_objects_uid = d.custom_objects_uid
	  ) ro on d.object_name = ro.object_name and u.role_uid = ro.role_id
  WHERE 
    [type] = 'U'
    and object_type = 'M'
    and c.row_status_flag = 704
    and d.object_name like 'm_%'
    and d.attribute_value <> ro.attribute_value

ORDER BY
	users_id