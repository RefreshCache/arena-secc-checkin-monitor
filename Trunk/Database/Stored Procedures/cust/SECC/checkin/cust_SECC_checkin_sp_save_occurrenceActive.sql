USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_save_occurrenceActive]    Script Date: 09/20/2011 17:19:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_save_occurrenceActive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_save_occurrenceActive]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_save_occurrenceActive]    Script Date: 09/20/2011 17:19:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[cust_SECC_checkin_sp_save_occurrenceActive]
	@UserId varchar(50),
	@OccurrenceClosed bit,
	@FilteredOccurrences varchar(8000) = ''
AS
BEGIN

IF LEN(@FilteredOccurrences) = 0 
	BEGIN
		UPDATE core_occurrence Set
			[date_modified] = GETDATE(), 
			[modified_by] = @UserID, 
			[occurrence_closed] = @OccurrenceClosed
		WHERE [check_in_start] <> '1/1/1900'
			AND [check_in_start] <= GETDATE()
			AND [check_in_end] >= GETDATE()
	END
ELSE
	BEGIN
		UPDATE core_occurrence Set
			[date_modified] = GETDATE(), 
			[modified_by] = @UserID, 
			[occurrence_closed] = @OccurrenceClosed
		WHERE [check_in_start] <> '1/1/1900'
			AND [check_in_start] <= GETDATE()
			AND [check_in_end] >= GETDATE()
			AND occurrence_type IN 
				(
					SELECT occurrence_type_id
					FROM core_occurrence_type 
					WHERE group_id in (SELECT CAST(ITEM AS INT) from dbo.fnSplit(@FilteredOccurrences))
				)		
	END

END


GO

