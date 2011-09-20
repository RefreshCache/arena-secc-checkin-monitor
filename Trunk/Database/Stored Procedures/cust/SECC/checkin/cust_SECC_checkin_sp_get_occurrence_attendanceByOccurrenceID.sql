USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_occurrence_attendanceByOccurrenceID]    Script Date: 09/20/2011 17:16:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_get_occurrence_attendanceByOccurrenceID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_get_occurrence_attendanceByOccurrenceID]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_occurrence_attendanceByOccurrenceID]    Script Date: 09/20/2011 17:16:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[cust_SECC_checkin_sp_get_occurrence_attendanceByOccurrenceID]
@OccurrenceID int,
@AttendanceStatus int

AS

IF @AttendanceStatus = 1 
BEGIN

	SELECT	
		ISNULL(a.occurrence_attendance_id,-1) as occurrence_attendance_id,
		a.security_code,
		a.check_in_time,
		a.check_out_time,
		a.occurrence_id,
		a.person_id,
		a.session_id,
		a.type,
		p.guid AS person_guid,
		FM.family_id,
		p.last_name,
		p.nick_name,
		p.first_name,
		P.nick_name + ' ' + p.last_name as person_name,
		RTRIM(RTRIM(ISNULL(P.last_name,'')) + ', ' + 
		CASE WHEN LEN(RTRIM(ISNULL(P.nick_name,''))) = 0 THEN RTRIM(ISNULL(P.first_name,''))
			 ELSE RTRIM(ISNULL(P.nick_name,'')) END) AS full_name,
			CASE p.record_status
		WHEN 0 THEN 'Active'
		WHEN 1 THEN 'Inactive'
		WHEN 2 THEN 'Pending'
		ELSE '-' END AS record_status,
		p.birth_date,
		BP.list_business_phone,
		MP.list_cell_phone,
		ADR.address_id,
		ADR.street_address_1 +
		CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
			CHAR(10) + CHAR(13) + ADR.street_address_2
		ELSE '' END AS Address,
		ADR.city,
		ADR.state,
		ADR.postal_code,
		ADR.country,
		a.attended,
		a.notes,
		a.pager,
		p.medical_information,
		(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid,
		p.guid,
		syst.system_name,
		syst.system_id
	FROM core_occurrence_attendance a WITH(NOLOCK)
	LEFT OUTER JOIN chkn_session sess WITH(NOLOCK) ON a.session_id = sess.session_id
	LEFT OUTER JOIN comp_system syst WITH(NOLOCK) ON sess.system_id = syst.system_id
	LEFT OUTER JOIN core_person p WITH(NOLOCK) ON p.person_id = a.person_id
	LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
	LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
	LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
	LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
	LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id
	WHERE occurrence_id = @OccurrenceID
	AND attended = 1
	ORDER BY last_name, first_name

END
ELSE
BEGIN

	IF @AttendanceStatus = -1
	BEGIN
	
		SELECT
			ISNULL(oa.occurrence_attendance_id,-1) as occurrence_attendance_id,
			oa.security_code,
			oa.check_in_time,
			oa.check_out_time,
			o.occurrence_id,
			pm.person_id,
			oa.session_id,
			oa.type,
			p.guid AS person_guid,
			FM.family_id,
			p.last_name,
			p.nick_name,
			p.first_name,
			P.nick_name + ' ' + p.last_name as person_name,
			RTRIM(RTRIM(ISNULL(P.last_name,'')) + ', ' + 
			CASE WHEN LEN(RTRIM(ISNULL(P.nick_name,''))) = 0 THEN RTRIM(ISNULL(P.first_name,''))
				 ELSE RTRIM(ISNULL(P.nick_name,'')) END) AS full_name,
			CASE p.record_status
			WHEN 0 THEN 'Active'
			WHEN 1 THEN 'Inactive'
			WHEN 2 THEN 'Pending'
			ELSE '-' END AS record_status,
			p.birth_date,
			BP.list_business_phone,
			MP.list_cell_phone,
			ADR.address_id,
			ADR.street_address_1 +
			CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
				CHAR(10) + CHAR(13) + ADR.street_address_2
			ELSE '' END AS Address,
			ADR.city,
			ADR.state,
			ADR.postal_code,
			ADR.country,
			CASE WHEN oa.attended is null THEN CAST(0 as bit) ELSE oa.attended END AS attended,
			CASE WHEN oa.notes is null THEN '' ELSE oa.notes END AS notes,
			CASE WHEN oa.pager is null THEN '' ELSE oa.pager END AS pager,
			p.medical_information,
			(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid
		FROM core_occurrence o WITH(NOLOCK)
		INNER JOIN core_profile_occurrence po WITH(NOLOCK) on o.occurrence_id = po.occurrence_id
		INNER JOIN core_profile_member pm WITH(NOLOCK) on pm.profile_id = po.profile_id
		INNER JOIN core_lookup slu WITH(NOLOCK) on slu.lookup_id = pm.status_luid
		INNER JOIN core_person p WITH(NOLOCK) on p.person_id = pm.person_id
		LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
		LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
		LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
		LEFT OUTER JOIN core_occurrence_attendance oa WITH(NOLOCK) on oa.occurrence_id = o.occurrence_id
			and oa.person_id = pm.person_id
		LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
		LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id
		WHERE o.occurrence_id = @OccurrenceID
		AND slu.lookup_qualifier IN ('P','A')
		
		UNION
		
		SELECT
			ISNULL(oa.occurrence_attendance_id,-1) as occurrence_attendance_id,
			oa.security_code,
			oa.check_in_time,
			oa.check_out_time,
			o.occurrence_id,
			p.person_id,
			oa.session_id,
			oa.type,
			p.guid AS person_guid,
			FM.family_id,
			p.last_name,
			p.nick_name,
			p.first_name,
			P.nick_name + ' ' + p.last_name as person_name,
			RTRIM(RTRIM(ISNULL(P.last_name,'')) + ', ' + 
			CASE WHEN LEN(RTRIM(ISNULL(P.nick_name,''))) = 0 THEN RTRIM(ISNULL(P.first_name,''))
				 ELSE RTRIM(ISNULL(P.nick_name,'')) END) AS full_name,
			CASE p.record_status
			WHEN 0 THEN 'Active'
			WHEN 1 THEN 'Inactive'
			WHEN 2 THEN 'Pending'
			ELSE '-' END AS record_status,
			p.birth_date,
			BP.list_business_phone,
			MP.cell_phone,
			ADR.address_id,
			ADR.street_address_1 +
			CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
				CHAR(10) + CHAR(13) + ADR.street_address_2
			ELSE '' END AS Address,
			ADR.city,
			ADR.state,
			ADR.postal_code,
			ADR.country,
			CASE WHEN oa.attended is null THEN CAST(0 as bit) ELSE oa.attended END AS attended,
			CASE WHEN oa.notes is null THEN '' ELSE oa.notes END AS notes,
			CASE WHEN oa.pager is null THEN '' ELSE oa.pager END AS pager,
			p.medical_information,
			(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid
		FROM core_occurrence o WITH(NOLOCK)
		INNER JOIN smgp_group_occurrence po WITH(NOLOCK) on o.occurrence_id = po.occurrence_id
		INNER JOIN smgp_group g WITH(NOLOCK) on g.group_id = po.group_id
		INNER JOIN core_person p WITH(NOLOCK) on p.person_id = g.leader_person_id
		LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
		LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
		LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
		LEFT OUTER JOIN core_occurrence_attendance oa WITH(NOLOCK) ON oa.occurrence_id = o.occurrence_id
			and oa.person_id = p.person_id
		LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
		LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id
		WHERE o.occurrence_id = @OccurrenceID
		
		UNION

		SELECT
			ISNULL(oa.occurrence_attendance_id,-1) as occurrence_attendance_id,
			oa.security_code,
			oa.check_in_time,
			oa.check_out_time,
			o.occurrence_id,
			pm.person_id,
			oa.session_id,
			oa.type,
			p.guid AS person_guid,
			FM.family_id,
			p.last_name,
			p.nick_name,
			p.first_name,
			P.nick_name + ' ' + p.last_name as person_name,
			RTRIM(RTRIM(ISNULL(P.last_name,'')) + ', ' + 
			CASE WHEN LEN(RTRIM(ISNULL(P.nick_name,''))) = 0 THEN RTRIM(ISNULL(P.first_name,''))
				 ELSE RTRIM(ISNULL(P.nick_name,'')) END) AS full_name,
			CASE p.record_status
			WHEN 0 THEN 'Active'
			WHEN 1 THEN 'Inactive'
			WHEN 2 THEN 'Pending'
			ELSE '-' END AS record_status,
			p.birth_date,
			BP.list_business_phone,
			MP.cell_phone,
			ADR.address_id,
			ADR.street_address_1 +
			CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
				CHAR(10) + CHAR(13) + ADR.street_address_2
			ELSE '' END AS Address,
			ADR.city,
			ADR.state,
			ADR.postal_code,
			ADR.country,
			CASE WHEN oa.attended is null THEN CAST(0 as bit) ELSE oa.attended END AS attended,
			CASE WHEN oa.notes is null THEN '' ELSE oa.notes END AS notes,
			CASE WHEN oa.pager is null THEN '' ELSE oa.pager END AS pager,
			p.medical_information,
			(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid
		FROM core_occurrence o WITH(NOLOCK)
		INNER JOIN smgp_group_occurrence po WITH(NOLOCK) on o.occurrence_id = po.occurrence_id
		INNER JOIN smgp_member pm WITH(NOLOCK) on pm.group_id = po.group_id
		INNER JOIN core_person p WITH(NOLOCK) on p.person_id = pm.person_id
		LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
		LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
		LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
		LEFT OUTER JOIN core_occurrence_attendance oa WITH(NOLOCK) on oa.occurrence_id = o.occurrence_id
			and oa.person_id = pm.person_id
		LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
		LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id
		WHERE o.occurrence_id = @OccurrenceID
		
		UNION
		
		SELECT
			ISNULL(a.occurrence_attendance_id,-1) as occurrence_attendance_id,
			a.security_code,
			a.check_in_time,
			a.check_out_time,
			a.occurrence_id,
			a.person_id,
			a.session_id,
			a.type,
			p.guid AS person_guid,
			FM.family_id,
			p.last_name,
			p.nick_name,
			p.first_name,
			P.nick_name + ' ' + p.last_name as person_name,
			RTRIM(RTRIM(ISNULL(P.last_name,'')) + ', ' + 
			CASE WHEN LEN(RTRIM(ISNULL(P.nick_name,''))) = 0 THEN RTRIM(ISNULL(P.first_name,''))
				 ELSE RTRIM(ISNULL(P.nick_name,'')) END) AS full_name,
			CASE p.record_status
			WHEN 0 THEN 'Active'
			WHEN 1 THEN 'Inactive'
			WHEN 2 THEN 'Pending'
			ELSE '-' END AS record_status,
			p.birth_date,
			BP.list_business_phone,
			MP.cell_phone,
			ADR.address_id,
			ADR.street_address_1 +
			CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
				CHAR(10) + CHAR(13) + ADR.street_address_2
			ELSE '' END AS Address,
			ADR.city,
			ADR.state,
			ADR.postal_code,
			ADR.country,
			a.attended,
			a.notes,
			a.pager,
			p.medical_information,
			(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid
		FROM core_occurrence_attendance a WITH(NOLOCK)
		LEFT OUTER JOIN core_person p WITH(NOLOCK) on p.person_id = a.person_id
		LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
		LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
		LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
		LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
		LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id
		WHERE occurrence_id = @OccurrenceID
	
		ORDER BY last_name, first_name

	END
	ELSE
	BEGIN

		SELECT	
			ISNULL(oa.occurrence_attendance_id,-1) as occurrence_attendance_id,
			oa.security_code,
			oa.check_in_time,
			oa.check_out_time,
			o.occurrence_id,
			pm.person_id,
			oa.session_id,
			oa.type,
			p.guid AS person_guid,
			FM.family_id,
			p.last_name,
			p.nick_name,
			p.first_name,
			P.nick_name + ' ' + p.last_name as person_name,
			RTRIM(RTRIM(ISNULL(P.last_name,'')) + ', ' + 
			CASE WHEN LEN(RTRIM(ISNULL(P.nick_name,''))) = 0 THEN RTRIM(ISNULL(P.first_name,''))
				 ELSE RTRIM(ISNULL(P.nick_name,'')) END) AS full_name,
			CASE p.record_status
			WHEN 0 THEN 'Active'
			WHEN 1 THEN 'Inactive'
			WHEN 2 THEN 'Pending'
			ELSE '-' END AS record_status,
			p.birth_date,
			BP.list_business_phone,
			MP.cell_phone,
			ADR.address_id,
			ADR.street_address_1 +
			CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
				CHAR(10) + CHAR(13) + ADR.street_address_2
			ELSE '' END AS Address,
			ADR.city,
			ADR.state,
			ADR.postal_code,
			ADR.country,
			CASE WHEN oa.attended is null THEN CAST(0 as bit) ELSE oa.attended END AS attended,
			CASE WHEN oa.notes is null THEN '' ELSE oa.notes END AS notes,
			CASE WHEN oa.pager is null THEN '' ELSE oa.pager END AS pager,
			p.medical_information,
			(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid
		FROM core_occurrence o WITH(NOLOCK)
		INNER JOIN core_profile_occurrence po WITH(NOLOCK) on o.occurrence_id = po.occurrence_id
		INNER JOIN core_profile_member pm WITH(NOLOCK) on pm.profile_id = po.profile_id
		INNER JOIN core_lookup slu WITH(NOLOCK) on slu.lookup_id = pm.status_luid
		INNER JOIN core_person p WITH(NOLOCK) on p.person_id = pm.person_id
		LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
		LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
		LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
		LEFT OUTER JOIN core_occurrence_attendance oa WITH(NOLOCK) ON oa.occurrence_id = o.occurrence_id
			and oa.person_id = pm.person_id
		LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
		LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id
		WHERE o.occurrence_id = @OccurrenceID
		AND (oa.attended IS NULL OR oa.attended = 0)
		AND slu.lookup_qualifier in ('P', 'A')
		
		UNION
		
		SELECT	
			ISNULL(oa.occurrence_attendance_id,-1) as occurrence_attendance_id,
			oa.security_code,
			oa.check_in_time,
			oa.check_out_time,
			o.occurrence_id,
			pm.person_id,
			oa.session_id,
			oa.type,
			p.guid AS person_guid,
			FM.family_id,
			p.last_name,
			p.nick_name,
			p.first_name,
			P.nick_name + ' ' + p.last_name as person_name,
			RTRIM(RTRIM(ISNULL(P.last_name,'')) + ', ' + 
			CASE WHEN LEN(RTRIM(ISNULL(P.nick_name,''))) = 0 THEN RTRIM(ISNULL(P.first_name,''))
				 ELSE RTRIM(ISNULL(P.nick_name,'')) END) AS full_name,
			CASE p.record_status
			WHEN 0 THEN 'Active'
			WHEN 1 THEN 'Inactive'
			WHEN 2 THEN 'Pending'
			ELSE '-' END AS record_status,
			p.birth_date,
			BP.list_business_phone,
			MP.cell_phone,
			ADR.address_id,
			ADR.street_address_1 +
			CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
				CHAR(10) + CHAR(13) + ADR.street_address_2
			ELSE '' END AS Address,
			ADR.city,
			ADR.state,
			ADR.postal_code,
			ADR.country,
			CASE WHEN oa.attended is null THEN CAST(0 as bit) ELSE oa.attended END AS attended,
			CASE WHEN oa.notes is null THEN '' ELSE oa.notes END AS notes,
			CASE WHEN oa.pager is null THEN '' ELSE oa.pager END AS pager,
			p.medical_information,
			(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid
		FROM core_occurrence o WITH(NOLOCK)
		INNER JOIN smgp_group_occurrence po WITH(NOLOCK) on o.occurrence_id = po.occurrence_id
		INNER JOIN smgp_member pm WITH(NOLOCK) on pm.group_id = po.group_id
		INNER JOIN core_person p WITH(NOLOCK) on p.person_id = pm.person_id
		LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
		LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
		LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
		LEFT OUTER JOIN core_occurrence_attendance oa WITH(NOLOCK) on oa.occurrence_id = o.occurrence_id
			and oa.person_id = pm.person_id
		LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
		LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id
		WHERE o.occurrence_id = @OccurrenceID
		AND (oa.attended IS NULL OR oa.attended = 0)
	

		UNION
		
		SELECT	
			ISNULL(a.occurrence_attendance_id,-1) as occurrence_attendance_id,
			a.security_code,
			a.check_in_time,
			a.check_out_time,
			a.occurrence_id,
			a.person_id,
			a.session_id,
			a.type,
			p.guid AS person_guid,
			FM.family_id,
			p.last_name,
			p.nick_name,
			p.first_name,
			P.nick_name + ' ' + p.last_name as person_name,
			p.last_name + ', ' + p.nick_name as full_name,
			CASE p.record_status
			WHEN 0 THEN 'Active'
			WHEN 1 THEN 'Inactive'
			WHEN 2 THEN 'Pending'
			ELSE '-' END AS record_status,
			BP.list_business_phone,
			MP.cell_phone,
			ADR.address_id,
			ADR.street_address_1 +
			CASE WHEN ADR.street_address_2 IS NOT NULL AND ADR.street_address_2 <> '' THEN
				CHAR(10) + CHAR(13) + ADR.street_address_2
			ELSE '' END AS Address,
			p.birth_date,
			ADR.city,
			ADR.state,
			ADR.postal_code,
			ADR.country,
			a.attended,
			a.notes,
			a.pager,
			p.medical_information,
			(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid
		FROM core_occurrence_attendance a WITH(NOLOCK)
		INNER JOIN core_person p WITH(NOLOCK) on p.person_id = a.person_id
		LEFT OUTER JOIN core_family_member FM WITH(NOLOCK) ON FM.person_id = P.person_id
		LEFT OUTER JOIN core_person_address PA WITH(NOLOCK) ON PA.person_id = P.person_id AND PA.primary_address = 1
		LEFT OUTER JOIN core_address ADR WITH(NOLOCK) ON ADR.address_id = PA.address_id
		LEFT OUTER JOIN core_v_phone_business BP WITH(NOLOCK) ON p.person_id = BP.person_id
		LEFT OUTER JOIN core_v_phone_cell MP WITH(NOLOCK) ON p.person_id = MP.person_id

		WHERE occurrence_id = @OccurrenceID
		AND attended = 0

		ORDER BY last_name, first_name

	END
		
END


GO

