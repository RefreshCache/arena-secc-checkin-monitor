USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_familyoccurrences]    Script Date: 09/20/2011 17:17:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_get_familyoccurrences]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_get_familyoccurrences]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_familyoccurrences]    Script Date: 09/20/2011 17:17:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[cust_SECC_checkin_sp_get_familyoccurrences]
	@OccurrenceAttendanceID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @familyid int 
	set @familyid = (select cfm.family_id from core_occurrence_attendance coa inner join core_family_member cfm on coa.person_id = cfm.person_id where coa.occurrence_attendance_id = @OccurrenceAttendanceID)

	SELECT coa.occurrence_attendance_id, 		
		RTRIM(RTRIM(ISNULL(cp.last_name,'')) + ', ' + 
		CASE WHEN LEN(RTRIM(ISNULL(cp.nick_name,''))) = 0 THEN RTRIM(ISNULL(cp.first_name,''))
			 ELSE RTRIM(ISNULL(cp.nick_name,'')) END) AS full_name, 
		co.location,
		co.occurrence_type 
	from core_occurrence_attendance coa WITH(NOLOCK)
	inner join core_occurrence co WITH(NOLOCK) on coa.occurrence_id = co.occurrence_id
	inner join core_person cp WITH(NOLOCK) on coa.person_id = cp.person_id
	inner join core_family_member cfm WITH(NOLOCK) on cfm.person_id = coa.person_id
	where cfm.family_id = @familyid AND coa.attended = 1  
	AND co.occurrence_start_time between CONVERT (date, GETDATE()) AND DATEADD(DAY, 1, CONVERT (date, GETDATE()))
	--(co.occurrence_start_time >= CONVERT (date, GETDATE()) OR co.check_in_start >= CONVERT (date, GETDATE()))
END


GO

