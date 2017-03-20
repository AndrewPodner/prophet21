SELECT
	c.customer_id
	,c.customer_name
	,a.mail_address1
	,a.mail_address2
	,a.mail_address3
	,a.mail_city
	,a.mail_state
	,a.mail_postal_code
	,a.mail_country
	,a.central_phone_number
	,a.central_fax_number
	,a.email_address
	,i.last_hard_touch_date
FROM
	p21_view_customer c
		INNER JOIN p21_view_address a ON
			c.customer_id = a.id
		LEFT JOIN crm_contact_information i WITH (NOLOCK) ON
			c.company_id = i.company_id
			AND c.customer_id = i.entity_link_id_dec
			AND 1203 = i.entity_type_cd
ORDER BY
  c.customer_name