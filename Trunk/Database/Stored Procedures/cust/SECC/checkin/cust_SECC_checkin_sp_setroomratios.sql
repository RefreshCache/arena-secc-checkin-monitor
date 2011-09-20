USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_setroomratios]    Script Date: 09/20/2011 17:18:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_setroomratios]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_setroomratios]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_setroomratios]    Script Date: 09/20/2011 17:18:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[cust_SECC_checkin_sp_setroomratios]
	@attendanceTypeId as int,
	@minLeaders as int,
	@peoplePerLeader as int
AS
BEGIN

	
	UPDATE core_occurrence_type
	SET min_leaders = @minLeaders,
		people_per_leader = @peoplePerLeader
	WHERE occurrence_type_id = @attendanceTypeId
		
	
END


GO

