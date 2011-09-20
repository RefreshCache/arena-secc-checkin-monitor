USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_panic]    Script Date: 09/20/2011 17:17:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_panic]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_panic]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_panic]    Script Date: 09/20/2011 17:17:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[cust_SECC_checkin_sp_panic]
	@enable as bit,
	@profileID as int
AS
BEGIN
	IF @enable = 1
		BEGIN
			UPDATE core_profile_member
			SET status_luid=255
			WHERE profile_id=@profileID
		END
	ELSE
		BEGIN
			UPDATE core_profile_member
			SET status_luid=316
			WHERE profile_id=@profileID
		END
END


GO

