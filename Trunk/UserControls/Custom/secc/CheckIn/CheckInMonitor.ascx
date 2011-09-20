<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CheckInMonitor.ascx.cs"
    Inherits="CheckInMonitor" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=9.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<%@ Register Src="~/UserControls/Custom/SECC/CheckIn/MovePerson.ascx" TagName="MovePerson"
    TagPrefix="secc" %>
<style type="text/css">
    .collapsible
    {
        text-decoration: none;
        font-weight: bold;
        color: #494747;
    }
    .headerLink
    {
        color: #494747;
        text-decoration: none;
    }
    .hiddenElement
    {
        display: none;
    }
    .noresults
    {
        text-align: center;
        font-style: italic;
        padding: 50px 0 50px 0;
        font-size: x-small;
    }
    .refreshlabel
    {
        padding: 0 5px 2px 0;
        float: right;
    }
    .refreshlabel2
    {
        font-weight: bold;
    }
    .footerRow
    {
        height: 16px;
        border-top: solid 1px gray;
        color: #494747;
    }
    .headerRow
    {
        height: 16px;
        border-bottom: solid 1px gray;
        color: #494747;
    }
    .commandpan
    {
        position: relative;
        background-color: #e8e5e5;
        padding: 5px;
        margin: 0;
        border-bottom: solid 1px gray;
        min-width: 725px;
        height: 30px;
        font-size: 10px;
        font-weight: bold;
    }
    .commandpan ul
    {
        margin: 0;
        padding: 0;
        list-style-type: none;
        width: auto;
        float: left;
    }
    .commandpan ul li
    {
        display: block;
        float: left;
        margin: 0 1px;
    }
    .commandpan a
    {
        display: block;
        float: left;
        background-color: #f4f2f2;
        padding: 6px;
        margin: 0px 5px 0px 0px;
        border: solid 1px gray;
        cursor: pointer;
        color: #494747;
        text-decoration: none;
    }
    .commandpan a:hover
    {
        background-color: White;
    }
    .commandpan a img
    {
        margin: 0;
        border: 0;
        vertical-align: middle;
        padding: 0px 2px 0px 0px;
    }
    a.panicon
    {
        background-color: #ffcccc;
        border: solid 1px red;
        color: Red;
    }
    a.panicon:hover
    {
        background-color: #ffe1e1;
    }
    a.panicoff
    {
    }
    .monitorPopup
    {
        height: 400px;
        width: 600px;
        overflow-y: scroll;
        overflow-x: hidden;
        padding-right: 20px;
    }
    .monitorPopup h2
    {
        font-size: 1.05em;
    }
    .monitorPopup h3
    {
        font-size: 0.70em;
        margin-bottom: 5px;
        width: 600px;
    }
    #popupTime
    {
        width: 600px;
    }
    #popupTime td
    {
        vertical-align: bottom;
        font-size: x-small;
    }
    #searchCriteria
    {
        vertical-align: baseline;
        font-size: x-small;
        padding-bottom: 5px;
    }
    .AttTypeCat
    {
        background-color: #f4f2f2;
    }
    .AttType
    {
        background-color: #f4f2f2;
    }
</style>

<script src="Include/scripts/jquery.1.3.2.min.js" type="text/javascript"></script>

<script type="text/javascript">
    function highlightListViewRow(itemid, itemColor, altItemColor, highlightColor) {
        var currentElement = $get(itemid);

        if (currentElement != null) {
            var oldBackground = getListViewNormalRowColor(currentElement, itemColor, altItemColor);
            currentElement.temp_onmouseover = currentElement.onmouseover;
            currentElement.temp_onmouseout = currentElement.onmouseout;
            currentElement.onmouseover = null;
            currentElement.onmouseout = null;

            var animations = new Array();
            var enableScript = "var _curEle = $get('" + currentElement.id + "');"
            enableScript += "_curEle.onmouseover = _curEle.temp_onmouseover;";
            enableScript += "_curEle.onmouseout = _curEle.temp_onmouseout;";

            Array.add(animations, new AjaxControlToolkit.Animation.ColorAnimation(currentElement, 0.5, 30, "style", "backgroundColor", highlightColor, highlightColor));
            Array.add(animations, new AjaxControlToolkit.Animation.ColorAnimation(currentElement, 0.20, 30, "style", "backgroundColor", highlightColor, oldBackground));
            Array.add(animations, new AjaxControlToolkit.Animation.ScriptAction(currentElement, 0, 0, enableScript));
            AjaxControlToolkit.Animation.SequenceAnimation.play(currentElement, 0, 0, animations, 1);
        }
    }
    
    function getListViewNormalRowColor(datagridrow, itemColor, altItemColor) {
        var bgc = datagridrow.style.backgroundColor.toLowerCase();
        if (datagridrow.className.toLowerCase() == 'listaltitem' || bgc == '#ffffff' || bgc == 'white' || bgc == 'rgb(255, 255, 255)')
            return altItemColor;
        else
            return itemColor;
    }

    function validateMovePerson() {   
        var ctrl = $get("<%= ((HiddenField)ucMovePerson.FindControl("destinationOccurrenceId")).ClientID %>");
           
        if(ctrl == null || ctrl.value == "") {
            alert("Please select destination (\"Move To\").");
            return false;
        }
        else if (parseInt(ctrl.value) < 0) {
            alert("Invalid selection. Please select an occurrence (indented the most).");
            return false;
        }

        return true;
  
    }  

    function validateMoveAttendees(source)
    {
        var doID = $get("<%= ((HiddenField)ucMovePerson.FindControl("destinationOccurrenceID")).ClientID %>");
        var doName = $get("<%= ((HiddenField)ucMovePerson.FindControl("destinationOccurrenceName")).ClientID %>");
        var isValid = true;

        var confimMsg = "Are you sure you want to move all attendees from " + source + "?";
        

        if(doID == null || doID.value == "")
        {
            alert("Please select destination (\"Move To\").");
            isValid = false;
        }
        else if(parseInt(doID.value) < 0) 
        {
            alert("Invalid selection. Please select an occurrence (indented the most).");
            isValid = false;
        }
        else if(!confirm(confimMsg))
        {
            isValid = false;
        }

        return isValid;

    }

    var isPopUpOpen = false, isTagsOpen = false, isSearchOpen = false, isHandlersAttached = false;
    var timer;
    
    function EndRequestHandler(sender, args) {
        eval($get("hiddenScripts").innerHTML);
        
        if(isHandlersAttached == false) {
            $(".modal-close").click(function(event) {
                closePopup();
            });
            
            isHandlersAttached = true;
        }
        
        if(!timer) {
            timer = $find('<%= tmrMain.ClientID %>');
        }
        
        if(isPopUpOpen) {
            if(timer.get_enabled()) {
                timer.set_enabled(false);
                timer._stopTimer();
            }
        } else {
            $get('<%= hfPopupOpen.ClientID %>').value = "";
            
            if(!timer.get_enabled()) {
                timer.set_enabled(true);
                timer._startTimer();
            } 
        }
        
        if(isTagsOpen) {
            swapTag();
        }
        
        if (isSearchOpen) {
            try {
                setTimeout(function() {$get("<%= SearchCriteria.ClientID %>").focus()}, 100);
            } catch(z) {}
        }
    }
        
    function openPopup() {
        isPopUpOpen = true;
        $get('<%= hfPopupOpen.ClientID %>').value = "1";
        
        if(!timer) {
            timer = $find('<%= tmrMain.ClientID %>');
        }
        
        timer.set_enabled(false);
        timer._stopTimer();
    }
    
    function openTags() {
        openPopup();
        isSearchOpen = false;
        isTagsOpen = true;
    }
    
    function openSearch() {
        openPopup();
        isSearchOpen = true;
    }
    
    function closePopup() {   
        isPopUpOpen = false;
        isTagsOpen = false;
        isSearchOpen = false;
        
        $find('mdlPopup').hide();
       
        $get('<%= hfPopupOpen.ClientID %>').value = "";
        
        if(!timer) {
            timer = $find('<%= tmrMain.ClientID %>');
        }
        
        timer.set_enabled(true);
        timer._startTimer();
        timer._doPostback();
    }
    
    function swapTag() {
        var objCont = document.getElementById("objContainer");  
        var obj = document.getElementById("objectTag").cloneNode();
        var dropOccId = document.getElementById("<%= dropChild.ClientID %>");
        var dropTag = document.getElementById("<%= tagsSelect.ClientID %>");
        
        if(dropTag.options.length > 0) {
        obj.data = "UserControls/Custom/SECC/Checkin/report.ashx?" + dropTag.options[dropTag.selectedIndex].value;
        obj.data += "," + dropOccId.options[dropOccId.selectedIndex].value;
        obj.data += ",<%= this.CurrentOrganization.OrganizationID.ToString() %>" + "#toolbar=0&navpanes=0&scrollbar=0&zoom=100";

        if(obj.firstChild == null) { 
            var objParam = document.createElement("param");
            objParam.name = "src";
            objParam.value = obj.data;
            
            obj.appendChild(objParam);
        }
        
        objCont.replaceChild(obj, objCont.lastChild);
        // "../../UserControls/Custom/SECC/Checkin/report.ashx?/Arena/Checkin/TestParentChildReceipt,1445928#toolbar=0&navpanes=0&scrollbar=0";
    }}

    function ConfirmBulkMove()
    {
        var confirmResponse = confirm("Move all attendees from this location?");
        return confirmResponse;

    }
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
</script>

<asp:Timer ID="tmrMain" Interval="10000" runat="server" OnTick="tmrMain_Tick" />
<asp:UpdatePanel ID="pnlMain" runat="server">
    <ContentTemplate>
        <div id="hiddenScripts" style="display: none; visibility: hidden;">
            <asp:Literal ID="BlingScripts" runat="server" />
        </div>
        <asp:HiddenField ID="hfOccurrence" runat="server" />
        <asp:HiddenField ID="hfPopupOpen" runat="server" EnableViewState="false" />
        <div style="border: solid 2px #c1bfbf; padding: 0; margin: 0;">
            <div class="commandpan">
                <ul>
                    <li>
                        <asp:LinkButton ID="lnkExpandAll" runat="server" CommandName="ExpandAll" OnCommand="ExpandCollapse"
                            ToolTip="Expand all Attendance Types and Categories"><img src="images/custom/secc/checkin/add_16.png" alt="Expand All" />Expand</asp:LinkButton>
                    </li>
                    <li>
                        <asp:LinkButton ID="lnkCollapseAll" runat="server" CommandName="CollapseAll" OnCommand="ExpandCollapse"
                            ToolTip="Collapse all Attendance Types and Categories"><img src="images/custom/secc/checkin/delete_16.png" alt="Collapse All" />Collapse</asp:LinkButton></li>
                    <asp:PlaceHolder ID="pnlRooms" runat="server">
                        <li>
                            <asp:LinkButton ID="lnkOpenAll" runat="server" CommandName="OpenAll" OnCommand="HeaderCommands"
                                OnClientClick="return confirm('Are you sure you want to open ALL checkins?');"
                                ToolTip="Open all check-in occurrences"><img src="images/custom/secc/checkin/ok_16.png" alt="Open All" />Open</asp:LinkButton></li>
                        <li>
                            <asp:LinkButton ID="lnkCloseAll" runat="server" CommandName="CloseAll" OnCommand="HeaderCommands"
                                OnClientClick="return confirm('Are you sure you want to close ALL checkins?');"
                                ToolTip="Close all check-in occurrences"><img src="images/custom/secc/checkin/close_b_16.png" alt="Close All" />Close</asp:LinkButton>
                        </li>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="pnlPanic" runat="server">
                        <li>
                            <asp:LinkButton ID="lnkPanic" runat="server" CommandName="Panic" OnCommand="HeaderCommands"><img src="images/custom/secc/checkin/emergency_16.png" alt="Panic" />Panic</asp:LinkButton>
                        </li>
                    </asp:PlaceHolder>
                    <li>
                        <asp:LinkButton ID="lnkViewAll" runat="server" CommandName="SearchAttendees" OnCommand="HeaderCommands"
                            OnClientClick="openSearch();" ToolTip="Search all active attendees and volunteers">
                    <img src="images/custom/secc/checkin/zoom_16.png" alt="Search" />Search</asp:LinkButton></li>
                    <li>
                        <asp:LinkButton ID="lnkRefresh" runat="server" CommandName="Refresh" OnCommand="HeaderCommands"
                            ToolTip="Refresh this page">
                    <img src="images/custom/secc/checkin/refresh_16.png" alt="Refresh" />Refresh</asp:LinkButton>
                    </li>
                </ul>
                <div class="refreshlabel">
                    <asp:Label ID="LabelRefresh" runat="server"></asp:Label>
                </div>
            </div>
            <table cellspacing="0" cellpadding="3" border="0" width="100%">
                <tr class="listHeader">
                    <td class="listHeader" style="width: 200px; max-width: 200px;">
                        Attendance Type Category
                        <br />
                        <span style="padding-left: 20px;">Attendance Type</span>
                    </td>
                    <td class="listHeader" style="width: 150px;">
                        Name
                    </td>
                    <td class="listHeader" style="width: 125px;">
                        Location
                    </td>
                    <td class="listHeader" style="width: 150px;">
                        Attendees / Volunteers
                    </td>
                    <td class="listHeader" style="width: 75px;">
                        Capacity <asp:Literal ID="lblWithRatio" runat="server" Text="(w/ratio)" />
                    </td>
                    <td class="listHeader" style="width: 160px;">
                        Check-in Times
                    </td>
                    <td class="listHeader" style="width: 175px; text-align: center;">
                        Actions
                    </td>
                </tr>
                <asp:Repeater ID="AttendanceTypeCategories" runat="server" OnItemDataBound="AttendanceTypeCategories_ItemDataBound">
                    <ItemTemplate>
                        <tr class="listAltItem AttTypeCat">
                            <td colspan="7">
                                <asp:ImageButton ID="AttendanceTypeCategoryImage" runat="server" ImageUrl="~/images/custom/secc/checkin/minus.gif"
                                    CommandName="AttendanceTypeCategory" CommandArgument='<%# Eval("AttendanceTypeCategoryId") %>'
                                    OnCommand="ExpandCollapse" ImageAlign="AbsMiddle" ToolTip="Toggle" />
                                <asp:LinkButton ID="AttendanceTypeCategoryLink" runat="server" Text='<%# Eval("AttendanceTypeCategoryName") %>'
                                    CommandName="AttendanceTypeCategory" CommandArgument='<%# Eval("AttendanceTypeCategoryId") %>'
                                    OnCommand="ExpandCollapse" CssClass="collapsible"></asp:LinkButton>
                            </td>
                        </tr>
                        <asp:Repeater ID="AttendanceTypes" runat="server" DataSource='<%# GetAttendanceTypes(Eval("AttendanceTypeCategoryId")) %>'
                            OnItemDataBound="AttendanceType_ItemDataBound">
                            <ItemTemplate>
                                <tr class="listAltItem AttType">
                                    <td colspan="7" style="padding-left: 20px;">
                                        <asp:ImageButton ID="AttendanceTypeImage" runat="server" ImageUrl="~/images/custom/secc/checkin/minus.gif"
                                            CommandName="AttendanceType" CommandArgument='<%# Eval("AttendanceTypeId") %>'
                                            OnCommand="ExpandCollapse" ImageAlign="AbsMiddle" ToolTip="Toggle" />
                                        <asp:LinkButton ID="AttendanceTypeLink" runat="server" Text='<%# Eval("AttendanceTypeName") %>'
                                            CommandName="AttendanceType" CommandArgument='<%# Eval("AttendanceTypeId") %>'
                                            OnCommand="ExpandCollapse" CssClass="collapsible"></asp:LinkButton>
                                    </td>
                                </tr>
                                <asp:ListView ID="listOccurrences" runat="server" DataSource='<%# GetOccurrences(Eval("AttendanceTypeId")) %>'
                                    OnItemDataBound="listOccurrences_ItemDataBound">
                                    <LayoutTemplate>
                                        <tr runat="server" id="itemPlaceholder" />
                                    </LayoutTemplate>
                                    <ItemTemplate>
                                        <tr id="tr1" runat="server" class='<%# Container.DataItemIndex % 2 == 0 ? "listAltItem" : "listItem"  %>'>
                                            <td>
                                            </td>
                                            <td>
                                                <asp:Literal ID="Label2" runat="server" Text='<%# Eval("Name") %>'></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:Literal ID="Label1" runat="server" Text='<%# Eval("Location") %>'></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:Image ID="AttendeesImage" runat="server" ImageUrl="~/images/custom/secc/checkin/clear.png"
                                                    Width="10" Height="14" />
                                                <asp:Literal ID="CurrentAttendees" runat="server" Text='<%# Eval("CurrentAttendees") %>'></asp:Literal>
                                                /
                                                <asp:Literal ID="CurrentVolunteers" runat="server" Text='<%# Eval("CurrentVolunteers") %>'></asp:Literal>
                                                <asp:Image ID="VolunteersImage" runat="server" ImageUrl="~/images/custom/secc/checkin/clear.png"
                                                    Width="10" Height="14" />
                                                <asp:Label ID="RatiosLabel" runat="server" Visible='<%# Eval("UseRoomRatios") %>'
                                                    Text='<%# this.RatiosText((Arena.Custom.SECC.Checkin.Entity.Occurrence)Container.DataItem) %>'
                                                    Font-Bold='<%# this.RatiosTextBold((Arena.Custom.SECC.Checkin.Entity.Occurrence)Container.DataItem) %>'
                                                    ForeColor='<%# (Arena.Custom.SECC.Checkin.Entity.RatioStatus)Eval("RatioStatus") == Arena.Custom.SECC.Checkin.Entity.RatioStatus.OverLimit 
                                                ? System.Drawing.Color.Red : System.Drawing.Color.Empty %>'></asp:Label>
                                            </td>
                                            <td>
                                                <asp:Literal ID="Label3" runat="server" Text='<%# (int)Eval("RoomCapacity") == 0 ? "" : Eval("RoomCapacity") %>'></asp:Literal>
                                                <asp:Literal ID="lblRatioCapacity" runat="server" Text='<%# this.GetRatioCapacity((Arena.Custom.SECC.Checkin.Entity.Occurrence)Container.DataItem) %>'
                                                    Visible='<%# this.DisplayRatioCapacity() %>'                                                 
                                                />
                                            </td>
                                            <td>
                                                <asp:Literal ID="Label4" runat="server" Text='<%# Eval("CheckinStartTime", "{0:t}") %>'></asp:Literal>
                                                -
                                                <asp:Literal ID="Label5" runat="server" Text='<%# Eval("CheckinEndTime", "{0:t}") %>'></asp:Literal>
                                            </td>
                                            <td style="text-align: center;">
                                                <!--~/images/sm_groups.gif-->
                                                <asp:ImageButton ID="RoomLink" runat="server" CommandName="ToggleRoom" CommandArgument='<%# Eval("Id") %>'
                                                    OnCommand="Occurrence_Command" Text='<%# (bool)Eval("IsOccurrenceClosed") || (bool)Eval("IsRoomClosed") ? "Open" : "Close" %>'
                                                    ImageUrl='<%# (bool)Eval("IsOccurrenceClosed") || (bool)Eval("IsRoomClosed") ? "~/images/custom/secc/checkin/door_close_24.png" : "~/images/custom/secc/checkin/door_ok_24.png" %>'
                                                    Visible='<%# this.ShowRoomSetting %>' ToolTip='<%# ((bool)Eval("IsOccurrenceClosed") || (bool)Eval("IsRoomClosed") ? "Open" : "Close") + " this check-in occurrence" %>'
                                                    Enabled='<%# (((Arena.Custom.SECC.Checkin.Entity.Occurrence)Container.DataItem).Available <= 0) ? false : true %>' />
                                                &nbsp;
                                                <asp:ImageButton ID="PeopleLink" runat="server" CommandName="ShowAttendees" CommandArgument='<%# Eval("Id") %>'
                                                    OnCommand="Occurrence_Command" ImageUrl="~/images/custom/secc/checkin/group_24.png"
                                                    ToolTip="View attendees and volunteers" OnClientClick="openPopup();" />
                                                &nbsp;
                                                <asp:HyperLink ID="DetailsLink" runat="server" Text="Details" Visible="<%# this.ShowDetailsSetting %>"
                                                    NavigateUrl='<%# string.Format("~/default.aspx?page={0}&OccurrenceID={1}", OccurrenceDetailPageIDSetting, Eval("Id")) %>'
                                                    CssClass="imgmiddle" ImageUrl="~/images/custom/secc/checkin/list_24.png" ToolTip="View additional details"></asp:HyperLink>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:ListView>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ItemTemplate>
                </asp:Repeater>
                <tr class="listItem" style="background-color: #e8e5e5;">
                    <td colspan="3" class="footerRow">
                        &nbsp;
                    </td>
                    <td colspan="4" class="footerRow">
                        <asp:Literal ID="TotalAttendees" runat="server"></asp:Literal>/<asp:Literal ID="TotalVolunteers"
                            runat="server"></asp:Literal>
                        (total)
                    </td>
                </tr>
            </table>
        </div>
    </ContentTemplate>
    <Triggers>
        <asp:AsyncPostBackTrigger ControlID="tmrMain" EventName="Tick" />
    </Triggers>
</asp:UpdatePanel>
<Arena:ModalPopup ID="mdlPopup" runat="server" BehaviorID="mdlPopup">
    <Content>
        <asp:UpdatePanel ID="upPopup" runat="server">
            <ContentTemplate>
                <div class="monitorPopup">
                    <asp:MultiView ID="mv" runat="server" ActiveViewIndex="0">
                        <asp:View ID="viewKids" runat="server">
                            <h2>
                                <asp:Literal ID="OccurrenceLabel" runat="server"></asp:Literal></h2>
                            <h3>
                                <asp:Literal ID="OccurrenceLabel2" runat="server"></asp:Literal></h3>
                            <table id="popupTime">
                                <tr>
                                    <td>
                                        <asp:DropDownList ID="dropRoomStatus" runat="server" OnSelectedIndexChanged="dropRoomStatus_SelectedIndexChanged" AutoPostBack="true">
                                            <asp:ListItem>Open</asp:ListItem>
                                            <asp:ListItem>Volunteers Only</asp:ListItem>
                                            <asp:ListItem>Closed</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:CheckBox ID="ShowActiveCheck" runat="server" Text="Show Active Only" AutoPostBack="true"
                                            OnCheckedChanged="ShowActiveCheck_CheckChanged" />
                                    </td>
                                    <td>
                                        <asp:Button ID="btnMoveAll" runat="server" Visible="false" OnClientClick="openPopup();" OnClick="btnMoveAll_Click" Text="Move All" CssClass="formButton" style="width:75px;" />
                                    </td>
                                    <td style="text-align: right;">
                                        <asp:Label ID="LabelRefresh2" runat="server" CssClass="refreshlabel2"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <asp:GridView ID="AttendeesList" runat="server" AutoGenerateColumns="false" CellSpacing="0"
                                OnRowDataBound="AttendeesList_RowDataBound" CellPadding="3" Width="600" BorderWidth="0"
                                AllowSorting="true" OnSorting="AttendeesList_Sorting" DataKeyNames="OccurrenceAttendanceId"
                                GridLines="None">
                                <Columns>
                                    <asp:TemplateField HeaderText="Name" HeaderStyle-CssClass="listHeader" SortExpression="FullName ASC"
                                        HeaderStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <asp:Image ID="LeaderImage" runat="server" ImageUrl="~/Images/businessman.png" ImageAlign="Middle"
                                                ToolTip="Volunteer" Visible='<%# ((Arena.Enums.OccurrenceAttendanceType)Eval("PersonType")) == Arena.Enums.OccurrenceAttendanceType.Leader %>' />
                                            <asp:HyperLink ID="hlName" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderStyle-CssClass="listHeader" HeaderText="Check-In" SortExpression="Checkin ASC"
                                        HeaderStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <%# ((DateTime)Eval("Checkin")).Date == DateTime.Today ? Eval("Checkin", "{0:t}") : Eval("Checkin", "{0:d} {0:t}")%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderStyle-CssClass="listHeader" HeaderText="Check-Out" SortExpression="Checkout ASC"
                                        HeaderStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <%# (DateTime)Eval("Checkout") == DateTime.Parse("1/1/1900") ? "" : ((DateTime)Eval("Checkout")).Date == DateTime.Today ? Eval("Checkout", "{0:t}") : Eval("Checkout", "{0:d} {0:t}")%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="SecurityCode" HeaderStyle-CssClass="listHeader" HeaderText="Security Code"
                                        SortExpression="SecurityCode ASC" HeaderStyle-HorizontalAlign="Left" />
                                    <asp:BoundField DataField="SystemName" HeaderStyle-CssClass="listHeader" HeaderText="Kiosk"
                                        SortExpression="SystemName ASC" HeaderStyle-HorizontalAlign="Left" />
                                    <asp:TemplateField HeaderStyle-CssClass="listHeader" HeaderText="Actions" HeaderStyle-HorizontalAlign="Center"
                                        ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkMove" CommandName="Move" CommandArgument='<%#Eval("Id").ToString()+","+ Eval("OccurrenceId").ToString()+","+ Eval("OccurrenceAttendanceId").ToString()+","+ Eval("PersonType").ToString() + "," +Eval("SecurityCode")%>'
                                                OnCommand="Attendee_Command" runat="server" Text="Move" OnClientClick="openPopup();"></asp:LinkButton>
                                            |
                                            <asp:LinkButton ID="lnkTags" CommandName="Tags" CommandArgument='<%# Eval("OccurrenceAttendanceId")%>'
                                                OnCommand="Attendee_Command" runat="server" Text="Tags" OnClientClick="openTags();"></asp:LinkButton>
                                            |
                                            <asp:LinkButton ID="lnkCheckout" CommandName="Checkout" CommandArgument='<%# Eval("OccurrenceId") + "," + Eval("Id") %>'
                                                OnCommand="Attendee_Command" runat="server" Text="Checkout"></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <HeaderStyle CssClass="listHeader" />
                                <RowStyle CssClass="listAltItem" BackColor="#ffffff" BorderWidth="0" BorderStyle="None" />
                                <AlternatingRowStyle CssClass="listItem" BackColor="#f4f2f2" />
                                <EmptyDataTemplate>
                                    <div class="noresults">
                                        There are no results to display...
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </asp:View>
                        <asp:View ID="viewSearch" runat="server">
                            <h2>
                                Search</h2>
                            <h3>
                                Searches all attendee and volunteer information for today's check-in occurrences.</h3>
                            <div id="searchCriteria">
                                <asp:TextBox ID="SearchCriteria" runat="server" Width="250px"></asp:TextBox>
                                <asp:CheckBoxList ID="SearchByCheckboxList" runat="server" RepeatDirection="Horizontal"
                                    RepeatLayout="Flow">
                                    <asp:ListItem Text="Name" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Security Code" Selected="True"></asp:ListItem>
                                </asp:CheckBoxList>
                            </div>
                            <asp:GridView ID="SearchList" runat="server" AutoGenerateColumns="false" CellSpacing="0"
                                OnRowDataBound="SearchList_RowDataBound" CellPadding="3" Width="600" BorderWidth="0"
                                AllowSorting="true" OnSorting="SearchList_Sorting" DataKeyNames="OccurrenceAttendanceId"
                                GridLines="None">
                                <Columns>
                                    <asp:TemplateField HeaderText="Name" HeaderStyle-CssClass="listHeader" SortExpression="FullName ASC"
                                        HeaderStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <asp:Image ID="LeaderImage" runat="server" ImageUrl="~/Images/businessman.png" ImageAlign="Middle"
                                                ToolTip="Volunteer" Visible='<%# ((Arena.Enums.OccurrenceAttendanceType)Eval("PersonType")) == Arena.Enums.OccurrenceAttendanceType.Leader %>' />
                                            <asp:HyperLink ID="hlName" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Location" HeaderStyle-CssClass="listHeader" HeaderText="Location"
                                        SortExpression="Location ASC" HeaderStyle-HorizontalAlign="Left" />
                                    <asp:TemplateField HeaderStyle-CssClass="listHeader" HeaderText="Check-In" SortExpression="Checkin ASC"
                                        HeaderStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <%# ((DateTime)Eval("Checkin")).Date == DateTime.Today ? Eval("Checkin", "{0:t}") : Eval("Checkin", "{0:d} {0:t}")%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderStyle-CssClass="listHeader" HeaderText="Check-Out" SortExpression="Checkout ASC"
                                        HeaderStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <%# (DateTime)Eval("Checkout") == DateTime.Parse("1/1/1900") ? "" : ((DateTime)Eval("Checkout")).Date == DateTime.Today ? Eval("Checkout", "{0:t}") : Eval("Checkout", "{0:d} {0:t}")%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="SecurityCode" HeaderStyle-CssClass="listHeader" HeaderText="Security Code"
                                        SortExpression="SecurityCode ASC" HeaderStyle-HorizontalAlign="Left" />
                                    <asp:BoundField DataField="SystemName" HeaderStyle-CssClass="listHeader" HeaderText="Kiosk"
                                        SortExpression="SystemName ASC" HeaderStyle-HorizontalAlign="Left" />
                                    <asp:TemplateField HeaderStyle-CssClass="listHeader" HeaderText="Actions" HeaderStyle-HorizontalAlign="Center"
                                        ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkMove" CommandName="Move" CommandArgument='<%#Eval("Id").ToString()+","+ Eval("OccurrenceId").ToString()+","+ Eval("OccurrenceAttendanceId").ToString()+","+ Eval("PersonType").ToString() + "," +Eval("SecurityCode")%>'
                                                OnCommand="Attendee_Command" runat="server" Text="Move" OnClientClick="openPopup();"></asp:LinkButton>
                                            |
                                            <asp:LinkButton ID="lnkTags" CommandName="Tags" CommandArgument='<%# Eval("OccurrenceAttendanceId")%>'
                                                OnCommand="Attendee_Command" runat="server" Text="Tags" OnClientClick="openTags();"></asp:LinkButton>
                                            |
                                            <asp:LinkButton ID="lnkCheckout" CommandName="Checkout" CommandArgument='<%# Eval("OccurrenceId") + "," + Eval("Id") %>'
                                                OnCommand="Attendee_Command" runat="server" Text="Checkout"></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <HeaderStyle CssClass="listHeader" />
                                <RowStyle CssClass="listItem" BackColor="#ffffff" />
                                <AlternatingRowStyle CssClass="listAltItem" BackColor="#f4f2f2" />
                                <EmptyDataTemplate>
                                    <div class="noresults">
                                        There are no results to display...
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </asp:View>
                        <asp:View ID="viewMove" runat="server">
                            <secc:MovePerson ID="ucMovePerson" runat="server" />
                        </asp:View>
                        <asp:View ID="viewTags" runat="server">
                            <div id="objContainer">
                                <object id="objectTag" type="application/pdf" width="100%" height="100%">
                                </object>
                            </div>
                        </asp:View>
                    </asp:MultiView>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </Content>
    <Buttons>
        <asp:UpdatePanel ID="upSaveFQ" runat="server">
            <ContentTemplate>
                <table width="600px" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left">
                            <asp:MultiView ID="viewPopupOptions" runat="server" ActiveViewIndex="0">
                                <asp:View ID="viewOptionsEmpty" runat="server">
                                </asp:View>
                                <asp:View ID="viewOptionTotals" runat="server">
                                    <table border="0" style="font-size: 10px;">
                                        <tr>
                                            <td>
                                                Attendees:
                                            </td>
                                            <td>
                                                <asp:Label ID="TotalAttendeesLabel" runat="server"></asp:Label>
                                            </td>
                                            <td style="padding-left: 10px;">
                                                Total:
                                            </td>
                                            <td>
                                                <asp:Label ID="GrandTotalLabel" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                Volunteers:
                                            </td>
                                            <td>
                                                <asp:Label ID="TotalVolunteersLabel" runat="server"></asp:Label>
                                                <asp:LinkButton ID="lnkIncreaseVol" runat="server" CommandName="AddVolunteer" OnCommand="PopupButton_Command"
                                                    ToolTip="Check-in phantom volunteer">+</asp:LinkButton>
                                            </td>
                                            <td style="padding-left: 10px;">
                                                Capacity:
                                            </td>
                                            <td>
                                                <asp:MultiView ID="viewRoomCap" runat="server" ActiveViewIndex="0">
                                                    <asp:View ID="viewLabel" runat="server">
                                                        <asp:Label ID="RoomCapLabel" runat="server"></asp:Label>
                                                        <asp:Label ID="RoomCapLeaderLabel" runat="server"></asp:Label>
                                                        <asp:LinkButton ID="lnkRoomCapEdit" runat="server" OnCommand="PopupButton_Command"
                                                            CommandName="EditRoomCap">edit</asp:LinkButton>
                                                    </asp:View>
                                                    <asp:View ID="viewModify" runat="server">
                                                        <asp:TextBox ID="txtRoomCap" runat="server" Width="30" MaxLength="3"></asp:TextBox>
                                                        <asp:CheckBox ID="chkRoomCapLeaders" runat="server" Text="Include Leaders" />
                                                        <asp:LinkButton ID="lnkRoomCapCancel" runat="server" OnCommand="PopupButton_Command"
                                                            CommandName="CancelRoomCap">cancel</asp:LinkButton>
                                                        &#124;
                                                        <asp:LinkButton ID="lnkRoomCapSave" runat="server" OnCommand="PopupButton_Command"
                                                            CommandName="SaveRoomCap">save</asp:LinkButton>
                                                    </asp:View>
                                                </asp:MultiView>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:View>
                                <asp:View ID="viewOptionTags" runat="server">
                                    <div id="divTags" style="font-size: smaller;">
                                        Member:
                                        <asp:DropDownList ID="dropChild" runat="server" DataTextField="FullName" DataValueField="OccurrenceAttendanceId" 
                                            OnSelectedIndexChanged="dropChild_SelectedIndexChanged" AutoPostBack="true">
                                        </asp:DropDownList>
                                        Tag:
                                        <asp:DropDownList ID="tagsSelect" runat="server" onchange="swapTag();" EnableViewState="false">
                                        </asp:DropDownList>
                                    </div>
                                </asp:View>
                            </asp:MultiView>
                        </td>
                        <td align="right">
                            <asp:Button ID="PopupButton1" runat="server" Text="Refresh" CssClass="formButton"
                                CausesValidation="false" OnCommand="PopupButton_Command" Width="75px" />
                            <input id="popupCloseBtn" type="button" value="Close" class="formButton" style="width: 75px;"
                                onclick="closePopup();" />
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </asp:UpdatePanel>
    </Buttons>
</Arena:ModalPopup>
