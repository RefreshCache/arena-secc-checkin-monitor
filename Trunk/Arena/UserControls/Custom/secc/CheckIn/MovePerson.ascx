<%@ Control Language="C#" AutoEventWireup="true" CodeFile="MovePerson.ascx.cs" Inherits="Arena.Custom.SECC.Checkin.MovePerson" %>
<%@ Register TagPrefix="componentart" Namespace="ComponentArt.Web.UI" Assembly="ComponentArt.Web.UI" %>


<asp:Panel ID="pnlMovePerson" CssClass="formItem" Visible="false" runat="server">
    <h2>Move - <asp:Label ID="lblPerson" runat="server"></asp:Label></h2>
    <h3 style="font-size: x-small;">Currently In:</h3>
    <asp:MultiView ID="multVwSourceOccurrence" ActiveViewIndex="0" runat="server">
        <asp:View ID="vwOccurrenceExists" runat="server">
            <asp:Label ID="lblSourceAttendanceTypeCat" Text="<%# SourceOccurrence.AttendanceTypeCategoryName %>" runat="server" /><br />
            &nbsp;&nbsp;&nbsp;<asp:Label ID="lblSourceAttendanceType" Text="<%# SourceOccurrence.AttendanceTypeName %>" runat="server" /><br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="lblSourceOccurrence" Text="<%# SourceOccurrence.Name %>" runat="server" /> - <asp:Label ID="lblLocation" Text="<%# SourceOccurrence.Location %>" runat="server" />
        </asp:View>
        <asp:View ID="vwNoOccurrence" runat="server">&nbsp;&nbsp;&nbsp;None.</asp:View>
    </asp:MultiView>
    <br />
    <h3 style="font-size: x-small;">Move To:</h3>
 
    <componentart:TreeView ID="tvDestinationOccurrence" EnableViewState="true" DragAndDropEnabled="false" 
        NodeEditingEnabled="false" KeyboardEnabled="true" AutoPostBackOnSelect="true" AutoScroll="true"
        CssClass="TreeView" NodeCssClass="TreeNode" SelectedNodeCssClass = "SelectedTreeNode"  
        HoverNodeCssClass = "TreeNode" NodeEditCssClass = "NodeEdit" LineImageWidth="0x13" LineImageHeight="20" 
        DefaultImageWidth="0x10" DefaultImageHeight="0x10" ItemSpacing="0" NodeLabelPadding="3" 
        ParentNodeImageUrl = "~/include/ComponentArt/TreeView/images/page.gif" 
        LeafNodeImageUrl = "~/include/ComponentArt/TreeView/images/page.gif" ShowLines="true" 
        LineImagesFolderUrl = "~/include/ComponentArt/TreeView/images/lines" Width="500" Height="250"
        BorderWidth="1" BorderStyle="Solid" BorderColor="Gray" 
        OnNodeExpanded="tvDestinationOccurrence_NodeExpanded"
        OnNodeSelected="tvDestinationOccurrence_NodeSelected"
        runat="server"></componentart:TreeView>   
        
    <asp:HiddenField ID="destinationOccurrenceId" runat="server"/>
    <asp:HiddenField ID="destinationOccurrenceName" runat="server"/>
</asp:Panel>