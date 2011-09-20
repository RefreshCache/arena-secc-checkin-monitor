USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_panic]    Script Date: 09/20/2011 17:17:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cust_SECC_checkin_sp_get_panic]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cust_SECC_checkin_sp_get_panic]
GO

USE [ArenaDB]
GO

/****** Object:  StoredProcedure [dbo].[cust_SECC_checkin_sp_get_panic]    Script Date: 09/20/2011 17:17:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[cust_SECC_checkin_sp_get_panic]
	-- Add the parameters for the stored procedure here
	@panicProfileID as int,
	@panicMode as bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	SET @panicMode = (CASE WHEN (
		SELECT COUNT(*) 
		FROM core_profile_member WITH(NOLOCK) 
		WHERE profile_id=@panicProfileID AND status_luid = 255) > 0 THEN 1 ELSE 0 END)
		
END


GO

