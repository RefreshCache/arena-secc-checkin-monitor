USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_occurrenceActive]    Script Date: 09/20/2011 17:15:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_get_occurrenceActive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_get_occurrenceActive]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_occurrenceActive]    Script Date: 09/20/2011 17:15:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--             UPDATES                          
-- 2/15/2011 - Chris Funk  - Added Attendance Type Sort Order (ot.type_order) to result set.
-- =============================================
CREATE PROCEDURE [dbo].[cust_SECC_checkin_sp_get_occurrenceActive]
	-- Add the parameters for the stored procedure here
	@lookup_type_id INT = 0 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT 	
	O.occurrence_id,
	O.location,
	O.occurrence_closed,
	O.check_in_start,
	O.check_in_end,
	O.occurrence_type,
	O.occurrence_name,
	O.occurrence_start_time,
	O.occurrence_end_time,
	Ot.type_name,	
	Ot.min_leaders,
	Ot.people_per_leader,
	Ot.use_room_ratios,
	ot.type_order,
	Otg.group_id,
	Otg.group_name,
	l.max_people,
	l.location_id,
	l.include_leaders_for_max_people,
	l.room_closed,
	(SELECT COUNT(*) 
		FROM core_occurrence_attendance WITH(NOLOCK)
		WHERE occurrence_id = O.occurrence_id
		AND attended = 1 AND check_in_time >= O.check_in_start AND check_out_time = '1/1/1900' AND [type] = 1) AS current_attendees,
	(SELECT COUNT(*) FROM core_occurrence_attendance WITH(NOLOCK)
		WHERE occurrence_id = O.occurrence_id
		AND attended = 1 AND check_in_time >= O.check_in_start AND check_out_time = '1/1/1900' AND [type] = 2) AS current_volunteers,
	cast(otr.occurrence_type_ratio_value as int) as occurrence_type_ratio_value

FROM core_occurrence O WITH(NOLOCK)
INNER JOIN core_occurrence_type Ot WITH(NOLOCK) ON Ot.occurrence_type_id = O.occurrence_type
INNER JOIN core_occurrence_type_group Otg WITH(NOLOCK) ON Ot.group_id = Otg.group_id
INNER JOIN orgn_location l WITH(NOLOCK) ON l.location_id = O.location_id
LEFT OUTER JOIN (SELECT lookup_value as occurrence_type, lookup_qualifier AS occurrence_type_ratio_value
			FROM core_lookup WITH(NOLOCK)
			WHERE lookup_type_id = @lookup_type_id AND active = 1) otr on cast(Ot.occurrence_type_id as varchar) = otr.occurrence_type
WHERE O.check_in_start <> '1/1/1900'
AND O.check_in_start <= GETDATE()
AND O.check_in_end >= GETDATE()
ORDER BY O.occurrence_name


END



GO

