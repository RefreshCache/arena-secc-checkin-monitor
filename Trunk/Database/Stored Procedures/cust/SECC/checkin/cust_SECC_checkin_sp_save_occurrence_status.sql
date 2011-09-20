USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_save_occurrence_status]    Script Date: 09/20/2011 17:18:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_save_occurrence_status]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_save_occurrence_status]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_save_occurrence_status]    Script Date: 09/20/2011 17:18:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[cust_SECC_checkin_sp_save_occurrence_status]
	@OccurrenceID int,
	@UserId varchar(50),
	@OccurrenceClosed bit
AS
BEGIN
		UPDATE core_occurrence Set
		[date_modified] = GETDATE(), 
		[modified_by] = @UserID, 
		[occurrence_closed] = @OccurrenceClosed
	WHERE
		occurrence_id = @OccurrenceID
END


GO

