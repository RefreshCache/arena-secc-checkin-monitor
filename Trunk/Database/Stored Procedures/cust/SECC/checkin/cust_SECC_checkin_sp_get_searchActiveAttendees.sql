USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_searchActiveAttendees]    Script Date: 09/20/2011 17:16:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_get_searchActiveAttendees]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_get_searchActiveAttendees]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_searchActiveAttendees]    Script Date: 09/20/2011 17:16:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[cust_SECC_checkin_sp_get_searchActiveAttendees]
	-- Add the parameters for the stored procedure here
	@name1 nvarchar(40) = NULL,
	@name2 nvarchar(40) = NULL,
	@securityCode varchar(6) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
		a.attended,
		a.notes,
		a.pager,
		p.medical_information,
		(SELECT ISNULL(CAST(guid as varchar(80)),'') FROM util_blob where blob_id = P.blob_id) AS photo_guid,
		p.guid,
		O.occurrence_name,
		O.occurrence_type,
		Ot.[type_name],
		l.location_name as location,
		syst.system_name,
		syst.system_id
	FROM core_occurrence_attendance a WITH(NOLOCK)
	INNER JOIN core_occurrence O WITH(NOLOCK) on a.occurrence_id = O.occurrence_id
	INNER JOIN core_occurrence_type Ot WITH(NOLOCK) ON Ot.occurrence_type_id = O.occurrence_type
	INNER JOIN core_occurrence_type_group Otg WITH(NOLOCK) ON Ot.group_id = Otg.group_id
	INNER JOIN orgn_location l WITH(NOLOCK) ON l.location_id = O.location_id
	INNER JOIN core_person p WITH(NOLOCK) ON p.person_id = a.person_id
	LEFT OUTER JOIN chkn_session sess WITH(NOLOCK) ON a.session_id = sess.session_id
	LEFT OUTER JOIN comp_system syst WITH(NOLOCK) ON sess.system_id = syst.system_id
	WHERE a.check_in_time >= DATEADD(dd, DATEDIFF(dd,0,GETDATE()), 0) 
	AND (attended = 1)
	AND (
		((p.first_name LIKE '%' + @name1 + '%' OR p.nick_name LIKE '%' + @name1 + '%') AND p.last_name LIKE '%' + @name2 + '%') OR
		((p.first_name LIKE '%' + @name2 + '%' OR p.nick_name LIKE '%' + @name2 + '%') AND p.last_name LIKE '%' + @name1 + '%') OR
		((p.first_name LIKE '%' + @name1 + '%' OR p.nick_name LIKE '%' + @name1 + '%') AND @name2 IS NULL) OR
		(p.last_name LIKE '%' + @name1 + '%' AND @name2 IS NULL) OR
		(a.security_code LIKE '%' + @securityCode + '%')) 
	ORDER BY last_name, first_name

END


GO

