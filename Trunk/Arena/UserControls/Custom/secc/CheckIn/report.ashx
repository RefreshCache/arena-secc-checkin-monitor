<%@ WebHandler Language="C#" Class="report" %>

using System;
using System.Web;
using Microsoft.Reporting.WebForms;
using Arena;
using Arena.Organization;
using Arena.Reporting;

public class report : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.Buffer = true;
        context.Response.Clear();
        context.Response.ContentType = "application/pdf";
        context.Response.AddHeader("content-disposition", "inline;filename=file.pdf");
        

        string url = context.Request.RawUrl;
        string[] ids = url.Substring(url.IndexOf('?') + 1).Split(',', '#');

        if (ids.Length != 3) {
            return;
        }

        Organization org = new Organization(int.Parse(ids[2]));
        ReportCredentials creds = new ReportCredentials();
        byte[] bits;

        creds.LoadByOrganizationId(int.Parse(ids[2]));

        using (ReportViewer rv = new ReportViewer()) {

            rv.ServerReport.ReportServerCredentials = creds;
            rv.ServerReport.ReportServerUrl = new Uri(org.Settings["ReportServerUrl"]);
            rv.ServerReport.ReportPath = ids[0]; // org.Settings["ReportServerRoot"] + ids[0] // "/Checkin/ChildTag_Josh";
            rv.ServerReport.SetParameters(new System.Collections.Generic.List<Microsoft.Reporting.WebForms.ReportParameter>() { 
            new Microsoft.Reporting.WebForms.ReportParameter("OccurrenceAttendanceID", ids[1]), //this.Request.QueryString["oaid"]), "1445928"
            new Microsoft.Reporting.WebForms.ReportParameter("AttributeGroupName", "Check-In") });

            // report.ashx?/Arena/Checkin/ChildTag,1445928,1#...

            Warning[] warnings;
            string[] streamids;
            string mimeType, encoding, extension;

            bits = rv.ServerReport.Render("PDF", null, out mimeType, out encoding, out extension, out streamids, out warnings);
        }
        
        context.Response.OutputStream.Write(bits, 0, bits.Length);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }
}