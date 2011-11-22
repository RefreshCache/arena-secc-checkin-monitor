using System;
using Arena.DataLayer.Core;
using System.Web.UI.WebControls;
using Arena.Portal;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;

using Arena.Custom.SECC.Checkin.Entity;
using System.Web.UI;
using System.Text;
using System.Collections;
using System.Reflection;
using System.Linq.Expressions;
using Microsoft.Reporting.WebForms;
using System.Web;


public partial class CheckInMonitor : PortalControl
{
    #region Module Settings...

    [NumericSetting("Refresh Timer", "The amount of time (in seconds) to wait before updating. Default is 10.", false)]
    public string TimerSetting { get { return Setting("Timer", "", false); } }

    [PageSetting("Person Detail Page", "The page that is used for displaying person details.", false, 7)]
    public string PersonDetailPageIDSetting { get { return Setting("PersonDetailPageID", "7", false); } }

    [PageSetting("Occurrence Detail Page", "The page that is used for displaying occurrence details.", false, 1115)]
    public string OccurrenceDetailPageIDSetting { get { return Setting("OccurrenceDetailPageID", "1115", false); } }

    [ImageSetting("Increase Image Path", "This is the small up arrow image that is displayed next to an attendee / volunteer that just checked in.", false)]
    public string IncreaseImageSetting { get { return Setting("IncreaseImage", "~/images/custom/secc/checkin/up_g.gif", false); } }

    [ImageSetting("Decrease Image Path", "This is the small down arrow image that is displayed next to an attendee / volunteer that just checked out.", false)]
    public string DecreaseImageSetting { get { return Setting("DecreaseImage", "~/images/custom/secc/checkin/down_r.gif", false); } }

    [TextSetting("Visible Attendance Type Categories", "If this setting is set, only the list of Attendance Type Categories with the following ID's will be listed.", false)]
    public string AttTypeCatSetting { get { return Setting("AttTypeCat", null, false); } }
    private int[] _VisibleAttendanceTypeCategories = null;
    public int[] VisibleAttendanceTypeCategories
    {
        get
        {
            if (_VisibleAttendanceTypeCategories == null && !string.IsNullOrEmpty(AttTypeCatSetting)) {
                _VisibleAttendanceTypeCategories = AttTypeCatSetting.Split(new char[] { ',', ' ' }).Select(x => int.Parse(x)).ToArray();
            }

            return _VisibleAttendanceTypeCategories;
        }
    }

    [TextSetting("Additional Tags", "A comma delimited list of additional tags to display in the Tag Reprint dropdown (aside from what is already used for that attendance type.)", false)]
    public string AdditionalTagsSetting { get { return Setting("AdditionalTags", "", false); } }

    [BooleanSetting("Show Details", "Show/Hide the Details link.  Default is true.", false, true)]
    public bool ShowDetailsSetting { get { return bool.Parse(Setting("ShowDetails", "true", false)); } }

    [BooleanSetting("Show Panic", "Show/Hide the Panic link.  Default is true.", false, true)]
    public bool ShowPanicSetting { get { return bool.Parse(Setting("ShowPanic", "true", false)); } }

    [BooleanSetting("Open/Close All Rooms", "Show/Hide the Open/Close all rooms control.  Default is true.", false, true)]
    public bool ShowRoomsSetting { get { return bool.Parse(Setting("ShowRooms", "true", false)); } }

    [BooleanSetting("Open/Close Individual Room", "Show/Hide the Open/Close individual room control.  Default is true.", false, true)]
    public bool ShowRoomSetting { get { return bool.Parse(Setting("ShowRoom", "true", false)); } }

    [NumericSetting("Phantom Volunteer", "The ID of the phantom volunteer", false)]
    public int OperaGhostSetting { get { return int.Parse(Setting("OperaGhost", "-1", false)); } }

    [TagSetting("Panic Tag", "This links to the tag that activates/inactivates all members.  This should be a serving tag.  If empty, the Panic button will not display.", false)]
    public string PanicTagSetting { get { return Setting("PanicTag", "", false); } }

    [BooleanSetting("Allow Bulk Move", "Allow bulk move of attendees from one room to another.", false, true)]
    public bool AllowBulkMoveSetting { get { return bool.Parse(Setting("AllowBulkMove", "true", false)); } }

    [NumericSetting("Attendance Type Ratio Lookup Type ID", "ID for Attendance Type Ratios Lookup Type. If empty ratio capacity will not show.", false)]
    public int AttendanceTypeRatio_LookupTypeIDSetting { get { return int.Parse(Setting("AttendanceTypeRatio_LookupTypeID", "0", false)); } }

    
    #endregion

    #region Public Properties...

    /// <summary>
    /// Stores in a session variable list of active people in last response, is updated in Page_Unload event.
    /// Person objects in list ONLY save the Id, Checkin, and Checkout properties.
    /// Code for what properties are used is in dgAttendees_ItemDataBound
    /// </summary>
    public List<Person> LastPeople
    {
        get
        {
            if (_lastPeople == null) {
                _lastPeople = new List<Person>();

                if (Session[CurrentModule.ModuleInstanceID.ToString() + "last_people"] != null)
                    _lastPeople = (List<Person>)Session[CurrentModule.ModuleInstanceID.ToString() + "last_people"];
            }

            return _lastPeople;
        }
        set
        {
            Session[CurrentModule.ModuleInstanceID.ToString() + "last_people"] = value;
        }
    }
  
    /// <summary>
    /// Stores in a session variable list of active occurrences in last response, is updated in Page_Unload event.
    /// Occurrence objects in list ONLY save the Id, CurrentAttendees, and CurrentVolunteers properties.
    /// Code for what properties are used is in dgOccurrences_ItemDataBound
    /// </summary>
    public List<Occurrence> LastOccurrences
    {
        get
        {
            if (_lastOccurrences == null) {
                _lastOccurrences = new List<Occurrence>();

                if (Session[CurrentModule.ModuleInstanceID.ToString() + "last_attendance"] != null)
                    _lastOccurrences = (List<Occurrence>)Session[CurrentModule.ModuleInstanceID.ToString() + "last_attendance"];
            }

            return _lastOccurrences;
        }
        set
        {
            Session[CurrentModule.ModuleInstanceID.ToString() + "last_attendance"] = value;
        }
    }
 
    public List<int> HiddenAttendanceTypeCategories
    {
        get
        {
            if (_hiddenAttendanceTypeCategories == null) {
                _hiddenAttendanceTypeCategories = new List<int>();

                if (this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_hiddenAttendanceTypeCategories"] != null)
                    _hiddenAttendanceTypeCategories = (List<int>)this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_hiddenAttendanceTypeCategories"];
            }

            return _hiddenAttendanceTypeCategories;
        }
        set
        {
            this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_hiddenAttendanceTypeCategories"] = value;
        }
    }
    
    public List<int> HiddenAttendanceTypes
    {
        get
        {
            if (_hiddenAttendanceTypes == null) {
                _hiddenAttendanceTypes = new List<int>();

                if (this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_hiddenAttendanceTypes"] != null)
                    _hiddenAttendanceTypes = (List<int>)this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_hiddenAttendanceTypes"];
            }

            return _hiddenAttendanceTypes;
        }
        set
        {
            this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_hiddenAttendanceTypes"] = value;
        }
    }
    
    public string GridSortExpression
    {
        get
        {
            if (this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_gridSort"] != null)
                _gridSort = (string)this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_gridSort"];

            return _gridSort;
        }
        set
        {
            _gridSort = value;
            this.ViewState[CurrentModule.ModuleInstanceID.ToString() + "_gridSort"] = _gridSort;
        }
    }

    public string LabelPath { get; set; }

    #endregion

    #region Private Properties...

    private Arena.Custom.SECC.Checkin.DataLayer.CheckinData CD;
    private StringBuilder startupScripts;
    private List<Person> _lastPeople;
    private List<Occurrence> _lastOccurrences;
    private List<int> _hiddenAttendanceTypeCategories;
    private List<int> _hiddenAttendanceTypes;
    private string _gridSort;

    #endregion

    #region Page Events...

    protected void Page_Load(object sender, EventArgs e)
    {
        if (CD == null) {
            CD = new Arena.Custom.SECC.Checkin.DataLayer.CheckinData(AttendanceTypeRatio_LookupTypeIDSetting);
            
        }

        if (startupScripts == null)
            startupScripts = new StringBuilder();

        if (!Page.IsPostBack) {
            this.ShowOccurrences();
            this.UpdateTotalCount();

            lblWithRatio.Visible = DisplayRatioCapacity();

            int seconds = 0;
            if (Int32.TryParse(TimerSetting, out seconds))
                tmrMain.Interval = seconds * 1000;

            this.pnlRooms.Visible = this.ShowRoomsSetting;

            this.pnlPanic.Visible = string.IsNullOrEmpty(this.PanicTagSetting) ? false : this.ShowPanicSetting;

            LabelPath = String.Empty;
        }

        LabelRefresh.Text = DateTime.Now.ToString();
        LabelRefresh2.Text = DateTime.Now.ToString();
    }

    protected void Page_Unload(object sender, EventArgs e)
    {
        /// Saves the last occurrences/people viewed state (attendees, volunteers)
        /// for next post back comparison (to highlight changes.)
        this.LastOccurrences = _lastOccurrences;
        this.LastPeople = _lastPeople;
    }

    protected override void OnPreRender(EventArgs e)
    {
        BlingScripts.Text = "";

        if (startupScripts != null && !string.IsNullOrEmpty(startupScripts.ToString()))
            BlingScripts.Text = startupScripts.ToString();

        base.OnPreRender(e);
    }

    #endregion

    #region Control Events...

    protected void tmrMain_Tick(object sender, EventArgs e)
    {
        this.ShowOccurrences();
        this.ShowAttendees();
        this.UpdateTotalCount();
    }

    protected void AttendanceTypeCategories_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        Occurrence occ = ((Occurrence)e.Item.DataItem);

        if (this.HiddenAttendanceTypeCategories.Contains(occ.AttendanceTypeCategoryId)) {
            ((Repeater)e.Item.FindControl("AttendanceTypes")).Visible = false;
            ((ImageButton)e.Item.FindControl("AttendanceTypeCategoryImage")).ImageUrl = this.ResolveUrl("~/images/custom/secc/checkin/plus.gif");
        }
        else {
            ((Repeater)e.Item.FindControl("AttendanceTypes")).Visible = true;
            ((ImageButton)e.Item.FindControl("AttendanceTypeCategoryImage")).ImageUrl = this.ResolveUrl("~/images/custom/secc/checkin/minus.gif");
        }
    }

    protected void AttendanceType_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        Occurrence occ = ((Occurrence)e.Item.DataItem);

        if (this.HiddenAttendanceTypes.Contains(occ.AttendanceTypeId)) {
            ((ListView)e.Item.FindControl("listOccurrences")).Visible = false;
            ((ImageButton)e.Item.FindControl("AttendanceTypeImage")).ImageUrl = this.ResolveUrl("~/images/custom/secc/checkin/plus.gif");
        }
        else {
            ((ListView)e.Item.FindControl("listOccurrences")).Visible = true;
            ((ImageButton)e.Item.FindControl("AttendanceTypeImage")).ImageUrl = this.ResolveUrl("~/images/custom/secc/checkin/minus.gif");
        }
    }

    protected void listOccurrences_ItemDataBound(object sender, ListViewItemEventArgs e)
    {
        if (e.Item.ItemType == ListViewItemType.DataItem) {
            Occurrence currentOcc = (Occurrence)((ListViewDataItem)e.Item).DataItem;
            Occurrence lastOcc = this.LastOccurrences.SingleOrDefault(x => x.Id == currentOcc.Id);

            if (currentOcc.IsOccurrenceClosed || currentOcc.IsRoomClosed || currentOcc.Available <= 0)
                ((System.Web.UI.HtmlControls.HtmlTableRow)e.Item.FindControl("tr1")).Attributes["class"] = "listItemTextInactive";

            if (lastOcc != null) {
                /// Highlight row if any changes
                if (lastOcc.CurrentAttendees != currentOcc.CurrentAttendees || lastOcc.CurrentVolunteers != currentOcc.CurrentVolunteers) {
                    startupScripts.Append("highlightListViewRow(\"" + e.Item.FindControl("tr1").ClientID + "\", \"#f4f2f2\", \"#ffffff\", \"#fefebb\"); ");

                    Image img;

                    /// If Current Attendees is different than the old value
                    /// update image url with appropiate path
                    if (lastOcc.CurrentAttendees != currentOcc.CurrentAttendees) {
                        img = (Image)e.Item.FindControl("AttendeesImage");

                        if (currentOcc.CurrentAttendees > lastOcc.CurrentAttendees) {
                            img.ImageUrl = this.IncreaseImageSetting;
                            img.ToolTip = "+" + (currentOcc.CurrentAttendees - lastOcc.CurrentAttendees);
                        }
                        else {
                            img.ImageUrl = this.DecreaseImageSetting;
                            img.ToolTip = "-" + (lastOcc.CurrentAttendees - currentOcc.CurrentAttendees);
                        }

                        lastOcc.CurrentAttendees = currentOcc.CurrentAttendees;
                    }

                    /// If Current Volunteers is different than the old value
                    /// update image url with appropiate path
                    if (lastOcc.CurrentVolunteers != currentOcc.CurrentVolunteers) {
                        img = (Image)e.Item.FindControl("VolunteersImage");

                        if (currentOcc.CurrentVolunteers > lastOcc.CurrentVolunteers) {
                            img.ImageUrl = this.IncreaseImageSetting;
                            img.ToolTip = "+" + (currentOcc.CurrentVolunteers - lastOcc.CurrentVolunteers);
                        }
                        else {
                            img.ImageUrl = this.DecreaseImageSetting;
                            img.ToolTip = "-" + (lastOcc.CurrentVolunteers - currentOcc.CurrentVolunteers);
                        }

                        lastOcc.CurrentVolunteers = currentOcc.CurrentVolunteers;
                    }
                }
            }
            else
                this.LastOccurrences.Add(
                    new Occurrence()
                    {
                        Id = currentOcc.Id,
                        CurrentAttendees = currentOcc.CurrentAttendees,
                        CurrentVolunteers = currentOcc.CurrentVolunteers
                    });
        }
    }

    protected void AttendeesList_Sorting(object sender, GridViewSortEventArgs e)
    {
        List<Person> people;

        this.GridSortExpression = e.SortExpression;

        if (AttendeesList.DataSource == null)
            this.AttendeesDataBind();

        people = (List<Person>)AttendeesList.DataSource;

        IEnumerable _data = people;

        Type dataSourceType = _data.GetType();

        Type dataItemType = typeof(object);

        if (dataSourceType.HasElementType)
            dataItemType = dataSourceType.GetElementType();
        else if (dataSourceType.IsGenericType)
            dataItemType = dataSourceType.GetGenericArguments()[0];
        else if (_data is IEnumerable) {
            IEnumerator dataEnumerator = _data.GetEnumerator();

            if (dataEnumerator.MoveNext() && dataEnumerator.Current != null)
                dataItemType = dataEnumerator.Current.GetType();
        }

        //var fieldType = dataItemType.GetProperty(e.SortExpression);

        object sorterObject = null;

        Type sorterType = null;

        // We'll handle things like LINQ to SQL differently by passing the love
        // on to the provider.
        PropertyInfo property = dataItemType.GetProperty(e.SortExpression.Split('\u0020')[0]);

        sorterType = typeof(Arena.Custom.SECC.Checkin.Sort.GenericSorter<,>).MakeGenericType(dataItemType, property.PropertyType);

        sorterObject = Activator.CreateInstance(sorterType);

        AttendeesList.DataSource = sorterType.GetMethod("Sort", new Type[] { dataSourceType, typeof(string), typeof(SortDirection) })
            .Invoke(sorterObject, new object[] { _data, e.SortExpression.Split('\u0020')[0], e.SortExpression.EndsWith("ASC") ? SortDirection.Ascending : SortDirection.Descending });

        if (e.SortExpression.EndsWith("ASC"))
            e.SortExpression = e.SortExpression.Replace("ASC", "DESC");
        else
            e.SortExpression = e.SortExpression.Replace("DESC", "ASC");

        foreach (DataControlField dcf in AttendeesList.Columns)
            if (dcf.SortExpression.StartsWith(e.SortExpression.Split('\u0020')[0])) {
                dcf.SortExpression = e.SortExpression;
                break;
            }

        AttendeesList.DataBind();
    }

    protected void AttendeesList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        /// Header row will have a NULL DataItem
        if (e.Row.DataItem != null) {
            Person currentPerson = (Person)e.Row.DataItem;

            Occurrence occ = CD.Occurrences.SingleOrDefault(x => x.Id == currentPerson.OccurrenceId);

            if (currentPerson.Checkin.Date != DateTime.Now.Date || currentPerson.Checkout != DateTime.Parse("1/1/1900")) {
                e.Row.CssClass = "listItemTextInactive";

                LinkButton lnkButton = e.Row.FindControl("lnkCheckout") as LinkButton;
                lnkButton.OnClientClick = "";
                lnkButton.Enabled = false;

                lnkButton = e.Row.FindControl("lnkMove") as LinkButton;
                lnkButton.Enabled = false;

                lnkButton = e.Row.FindControl("lnkTags") as LinkButton;
                lnkButton.Enabled = false;
            }
            else {
                LinkButton lnkButton = e.Row.FindControl("lnkCheckout") as LinkButton;
                lnkButton.OnClientClick = "return confirm('Are you sure you want to check \\'" + currentPerson.FullName.Replace("'", "\\\'") + "\\' out of " + occ.Location + "?');";
            }

            Person lastRow = this.LastPeople.SingleOrDefault(x => x.OccurrenceAttendanceId == currentPerson.OccurrenceAttendanceId);

            if (lastRow != null) {
                if (currentPerson.Checkin != lastRow.Checkin || currentPerson.Checkout != lastRow.Checkout) {
                    startupScripts.Append("setTimeout('highlightListViewRow(\"" + e.Row.ClientID + "\", \"#f4f2f2\", \"#ffffff\", \"#fefebb\")', 500);");

                    lastRow.Checkin = currentPerson.Checkin;
                    lastRow.Checkout = currentPerson.Checkout;
                }
            }
            else {
                this.LastPeople.Add(new Person() { OccurrenceAttendanceId = currentPerson.OccurrenceAttendanceId, Checkin = currentPerson.Checkin, Checkout = currentPerson.Checkout });

                /// We don't need a flash for checkins on previous days
                if (currentPerson.Checkin >= DateTime.Today)
                    startupScripts.Append("setTimeout('highlightListViewRow(\"" + e.Row.ClientID + "\", \"#f4f2f2\", \"#ffffff\", \"#fefebb\")', 500);");
            }


            HyperLink hl = e.Row.FindControl("hlName") as HyperLink;
            if (hl != null) {
                hl.NavigateUrl = string.Format("~/default.aspx?page={0}&guid={1}", PersonDetailPageIDSetting, currentPerson.PersonGuid);
                hl.ToolTip = "Age: " + decimal.Floor((decimal)DateTime.Now.Subtract(currentPerson.BirthDate).TotalDays / 365).ToString();
                hl.Text = currentPerson.FullName;
            }
        }
    }

    protected void SearchList_Sorting(object sender, GridViewSortEventArgs e)
    {
        string name1 = null, name2 = null, code = null;

        this.SplitSearchQuery(out name1, out name2, out code);

        SearchList.DataSource = CD.SearchAttendees(name1, name2, code);

        IEnumerable _data = CD.SearchAttendees(name1, name2, code);

        Type dataSourceType = _data.GetType();

        Type dataItemType = typeof(object);

        if (dataSourceType.HasElementType)
            dataItemType = dataSourceType.GetElementType();
        else if (dataSourceType.IsGenericType)
            dataItemType = dataSourceType.GetGenericArguments()[0];
        else if (_data is IEnumerable) {
            IEnumerator dataEnumerator = _data.GetEnumerator();

            if (dataEnumerator.MoveNext() && dataEnumerator.Current != null)
                dataItemType = dataEnumerator.Current.GetType();
        }

        //var fieldType = dataItemType.GetProperty(e.SortExpression);

        object sorterObject = null;

        Type sorterType = null;

        // We'll handle things like LINQ to SQL differently by passing the love
        // on to the provider.
        PropertyInfo property = dataItemType.GetProperty(e.SortExpression.Split('\u0020')[0]);

        sorterType = typeof(Arena.Custom.SECC.Checkin.Sort.GenericSorter<,>).MakeGenericType(dataItemType, property.PropertyType);

        sorterObject = Activator.CreateInstance(sorterType);

        SearchList.DataSource = sorterType.GetMethod("Sort", new Type[] { dataSourceType, typeof(string), typeof(SortDirection) })
            .Invoke(sorterObject, new object[] { _data, e.SortExpression.Split('\u0020')[0], e.SortExpression.EndsWith("ASC") ? SortDirection.Ascending : SortDirection.Descending });

        if (e.SortExpression.EndsWith("ASC"))
            e.SortExpression = e.SortExpression.Replace("ASC", "DESC");
        else
            e.SortExpression = e.SortExpression.Replace("DESC", "ASC");

        foreach (DataControlField dcf in SearchList.Columns)
            if (dcf.SortExpression.StartsWith(e.SortExpression.Split('\u0020')[0])) {
                dcf.SortExpression = e.SortExpression;
                break;
            }

        SearchList.DataBind();
    }

    protected void SearchList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.DataItem != null) {
            Person currentPerson = (Person)e.Row.DataItem;

            Occurrence occ = CD.Occurrences.SingleOrDefault(x => x.Id == currentPerson.OccurrenceId);

            if (currentPerson.Checkout != DateTime.Parse("1/1/1900") || occ == null || occ.CheckinEndTime < DateTime.Now) {
                e.Row.CssClass = "listItemTextInactive";

                LinkButton lnkButton = e.Row.FindControl("lnkCheckout") as LinkButton;
                lnkButton.OnClientClick = "";
                lnkButton.Enabled = false;

                lnkButton = e.Row.FindControl("lnkMove") as LinkButton;
                lnkButton.Enabled = false;

                //lnkButton = e.Row.FindControl("lnkTags") as LinkButton;
                //lnkButton.Enabled = false;
            }
            else {
                LinkButton lnkButton = e.Row.FindControl("lnkCheckout") as LinkButton;
                lnkButton.OnClientClick = "return confirm(\"Are you sure you want to check \'" + currentPerson.FullName.Replace("'", "\\\'") + "\' out of " + occ.Location + "?\");";
            }

            HyperLink hl = e.Row.FindControl("hlName") as HyperLink;
            if (hl != null) {
                hl.NavigateUrl = string.Format("~/default.aspx?page={0}&guid={1}", PersonDetailPageIDSetting, currentPerson.PersonGuid);
                hl.ToolTip = "Age: " + decimal.Floor((decimal)(DateTime.Now.Subtract(currentPerson.BirthDate).TotalDays / 365.2425)).ToString();
                hl.Text = currentPerson.FullName;
            }
        }
    }

    protected void ShowActiveCheck_CheckChanged(object sender, EventArgs e)
    {
        ShowAttendees();
    }

    protected void dropChild_SelectedIndexChanged(object sender, EventArgs e)
    {
        this.CreateTagDropdown(int.Parse(dropChild.SelectedValue));
    }


    protected void dropRoomStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        int id = int.Parse(hfOccurrence.Value);
        int locId = new Arena.Core.Occurrence(id).LocationID;

        switch (dropRoomStatus.SelectedIndex) {
            case 0 :
                CD.OpenCloseOccurrence(id, "ArenaOz", false);
                CD.OpenCloseRoom(locId, "ArenaOz", false);
                break;
            case 1 :
                CD.OpenCloseOccurrence(id, "ArenaOz", true);
                CD.OpenCloseRoom(locId, "ArenaOz", false);
                break;
            case 2 :
                CD.OpenCloseOccurrence(id, "ArenaOz", true);
                CD.OpenCloseRoom(locId, "ArenaOz", true);
                break;
        }
    }

    protected void btnMoveAll_Click(object sender, EventArgs e)
    {

        ucMovePerson.MoveType = MoveTypes.All;
        ucMovePerson.OccurrenceId = int.Parse(hfOccurrence.Value);
        ucMovePerson.VisibleAttendanceTypeCategories = this.VisibleAttendanceTypeCategories;
        ucMovePerson.Show();
        this.ChangePopupView(4);

    
    }

    protected void tagsSelect_SelectedIndexChanged (object sender, EventArgs e)
    {
        SetLabelPath();
    }

    #region Command Buttons...

    protected void ExpandCollapse(object sender, CommandEventArgs e)
    {
        List<int> l;
        System.Web.UI.Control ctrl;

        switch ((string)e.CommandName) {
            case "ExpandAll":
                this.HiddenAttendanceTypeCategories = new List<int>();
                this.HiddenAttendanceTypes = new List<int>();
                break;
            case "CollapseAll":
                this.HiddenAttendanceTypeCategories = this.GetAttendanceTypeCategories().Select(s => s.AttendanceTypeCategoryId).ToList();
                this.HiddenAttendanceTypes = this.CD.Occurrences.Select(s => s.AttendanceTypeId).Distinct().ToList();
                break;
            case "AttendanceTypeCategory":
                l = this.HiddenAttendanceTypeCategories;

                ctrl = ((Control)sender).Parent.FindControl("AttendanceTypes");

                if (ctrl.Visible)
                    l.Add(int.Parse((string)e.CommandArgument));
                else
                    l.Remove(int.Parse((string)e.CommandArgument));

                ctrl.Visible = !ctrl.Visible;

                this.HiddenAttendanceTypeCategories = l;
                break;
            case "AttendanceType":
                l = this.HiddenAttendanceTypes;

                ctrl = ((Control)sender).Parent.FindControl("listOccurrences");

                if (ctrl.Visible)
                    l.Add(int.Parse((string)e.CommandArgument));
                else
                    l.Remove(int.Parse((string)e.CommandArgument));

                ctrl.Visible = !ctrl.Visible;

                this.HiddenAttendanceTypes = l;
                break;
        }

        this.ShowOccurrences();
    }

    protected void HeaderCommands(object sender, CommandEventArgs e)
    {
        switch ((string)e.CommandName) {
            case "OpenAll":
                CD.OpenCloseAllOccurrences(base.CurrentUser.Identity.Name, false, VisibleAttendanceTypeCategories);
                this.ShowOccurrences();
                break;
            case "CloseAll":
                CD.OpenCloseAllOccurrences(base.CurrentUser.Identity.Name, true, VisibleAttendanceTypeCategories);
                this.ShowOccurrences();
                break;
            case "SearchAttendees":
                this.ChangePopupView(1);
                break;
            case "Refresh":
                this.ShowOccurrences();
                break;
            case "Panic":
                CD.SetPanicMode(int.Parse(this.PanicTagSetting.Split('|').Last()), bool.Parse(e.CommandArgument.ToString()));
                this.ShowOccurrences();
                break;
        }
    }

    protected void Occurrence_Command(object sender, CommandEventArgs e)
    {
        switch (e.CommandName) {
            case "ShowAttendees":
                hfOccurrence.Value = e.CommandArgument.ToString();
                this.ChangePopupView(0);
                break;
            case "ToggleRoom":      
                ImageButton lnk = (ImageButton)sender;
                var o = CD.Occurrences.FirstOrDefault(i => i.Id == int.Parse((string)e.CommandArgument));

                // If room is closed, then open room and occurrence.
                // Else toggle IsOccurrenceClosed property.
                if (o.IsRoomClosed) {
                    o.IsRoomClosed = false;
                    CD.OpenCloseRoom(o.LocationId, base.CurrentUser.Identity.Name, o.IsRoomClosed);

                    o.IsOccurrenceClosed = false;
                }
                else {
                    o.IsOccurrenceClosed = !o.IsOccurrenceClosed;
                }

                CD.OpenCloseOccurrence(o.Id, base.CurrentUser.Identity.Name, o.IsOccurrenceClosed);

                this.ShowOccurrences();
                break;
        }
    }

    protected void Attendee_Command(object sender, CommandEventArgs e)
    {
        switch (e.CommandName) {
            case "Move":
                string[] moveArguments = e.CommandArgument.ToString().Split(',');
                if (moveArguments.Length != 0) {
                    ucMovePerson.PersonId = int.Parse(moveArguments[0]);
                    ucMovePerson.OccurrenceId = int.Parse(moveArguments[1]);
                    ucMovePerson.OccurrenceAttendanceId = int.Parse(moveArguments[2]);
                    ucMovePerson.OccurrenceAttendanceType = (Arena.Enums.OccurrenceAttendanceType)Enum.Parse(typeof(Arena.Enums.OccurrenceAttendanceType), moveArguments[3]);
                    ucMovePerson.SecurityCode = moveArguments[4];
                    ucMovePerson.VisibleAttendanceTypeCategories = this.VisibleAttendanceTypeCategories;
                    ucMovePerson.MoveType = MoveTypes.Individual;

                    ucMovePerson.Show();
                    this.ChangePopupView(2);
                }
                break;
            case "Tags":
                dropChild.DataSource = CD.GetFamilyCheckIns(int.Parse(e.CommandArgument.ToString()));
                dropChild.DataBind();
                dropChild.SelectedValue = e.CommandArgument.ToString();

                this.CreateTagDropdown(int.Parse(e.CommandArgument.ToString()));

                this.ChangePopupView(3);

                break;
            case "Checkout":
                string[] s = e.CommandArgument.ToString().Split(',');
                CD.Checkout(int.Parse(s[0]), int.Parse(s[1]));
                this.ShowOccurrences();

                if (mv.ActiveViewIndex == 0)
                    this.ShowAttendees();
                else if (mv.ActiveViewIndex == 1)
                    this.ShowSearchResults();

                break;
        }
    }

    protected void PopupButton_Command(object sender, CommandEventArgs e)
    {
        switch (e.CommandName) {
            case "Refresh":
                this.ShowAttendees();
                break;
            case "Search":
                this.ShowSearchResults();
                break;
            case "AddVolunteer":

                CD.Checkin(this.OperaGhostSetting, int.Parse(e.CommandArgument.ToString()), string.Empty, Arena.Enums.OccurrenceAttendanceType.Leader);

                this.ShowAttendees();
                lnkIncreaseVol.Enabled = false;
                break;
            case "Move":
                Person person = CD.GetPersonById(ucMovePerson.PersonId);

                try {
                    //Move the person
                    string DestinationSecurityCode = null;
                    if (ucMovePerson.Move(false, out DestinationSecurityCode)) {
                        //Display confirmation
                        HiddenField ctrlDestOccName = ((HiddenField)ucMovePerson.FindControl("destinationOccurrenceName"));
                        string destinationOccurrenceName = "";
                        if (ctrlDestOccName != null)
                            destinationOccurrenceName = " to\\n\\r" + ctrlDestOccName.Value.ToString();

                        startupScripts.AppendFormat("alert('{0}{1} was moved{2}');",
                            person.FullName, person.PersonType == Arena.Enums.OccurrenceAttendanceType.Leader ? " (Leader)" : "",
                            destinationOccurrenceName);

                        //Bring up the person in new location
                        ChangePopupView(1);
                        SearchCriteria.Text = DestinationSecurityCode;
                        this.ShowSearchResults();
                    }
                }
                catch (Exception exc) {
                    startupScripts.AppendFormat("alert(\"Can not move {0}{1}. \\n\\rError: {2}\");", person.FullName,
                        (person.PersonType == Arena.Enums.OccurrenceAttendanceType.Leader ? " (Leader)" : ""), exc.Message +
                        (exc.InnerException != null ? " (" + exc.InnerException.Message + ")" : ""));
                }
                finally { person = null; }

                break;
            case "EditRoomCap":
                txtRoomCap.Text = RoomCapLabel.Text == "&#8734;" ? "0" : RoomCapLabel.Text;
                chkRoomCapLeaders.Checked = !RoomCapLeaderLabel.Text.Contains("without");
                viewRoomCap.ActiveViewIndex = 1;
                break;
            case "CancelRoomCap":
                viewRoomCap.ActiveViewIndex = 0;
                break;
            case "SaveRoomCap":
                var o = CD.Occurrences.FirstOrDefault(i => i.Id == int.Parse(hfOccurrence.Value));
                int roomCap;

                if (o != null && int.TryParse(txtRoomCap.Text, out roomCap)) {
                    /// save room cap
                    CD.SetRoomCap(o.LocationId, o.Id, roomCap, chkRoomCapLeaders.Checked);
                   
                    RoomCapLabel.Text = txtRoomCap.Text == "0" ? "&#8734;" : txtRoomCap.Text;
                    viewRoomCap.ActiveViewIndex = 0;
                }
                break;
            case "Move Attendees":
                string SourceName = string.Empty;
                string DestinationName = string.Empty;
                try
                {
                    SourceName = CD.Occurrences.Where(x => x.Id == int.Parse(hfOccurrence.Value)).FirstOrDefault().Location;
                    DestinationName = ((HiddenField)ucMovePerson.FindControl("destinationOccurrenceName")).Value.ToString();

                    if (ucMovePerson.MoveRoom(false))
                    {
                        startupScripts.AppendFormat("alert('Bulk Move Successful. All attendees from {0} have been moved to {1}');", SourceName, DestinationName);
                    }
                    hfOccurrence.Value = ((HiddenField)ucMovePerson.FindControl("destinationOccurrenceId")).Value;
                    ChangePopupView(0);
                }
                catch (Exception ex)
                {
                    startupScripts.AppendFormat("alert(\"Can not move attendees from {0} to {1}.\\n\\rError: {2}\");", SourceName, DestinationName, 
                        ex.Message + (ex.InnerException != null ? " (" + ex.InnerException.Message + ")" : ""));

                }
                
                break;
        }
    }

    #endregion

    #endregion

    #region Protected Methods...

    protected IEnumerable<Occurrence> GetAttendanceTypeCategories()
    {
        if (this.VisibleAttendanceTypeCategories == null)
            return CD.Occurrences.Distinct(new Arena.Custom.SECC.Checkin.Compare.AttendanceTypeCategoryComparer()).OrderBy(x => x.AttendanceTypeCategoryName);
        else
            return CD.Occurrences.Distinct(new Arena.Custom.SECC.Checkin.Compare.AttendanceTypeCategoryComparer()).Where(x => this.VisibleAttendanceTypeCategories.Contains(x.AttendanceTypeCategoryId)).OrderBy(x => x.AttendanceTypeCategoryName);
    }

    protected IEnumerable<Occurrence> GetAttendanceTypes(object id)
    {
        return CD.Occurrences.Where(x => x.AttendanceTypeCategoryId == (int)id).Distinct(new Arena.Custom.SECC.Checkin.Compare.AttendanceTypeComparer()).OrderBy(x => x.AttendanceTypeSortOrder);
    }

    protected IEnumerable<Occurrence> GetOccurrences(object id)
    {
        return CD.Occurrences.Where(x => x.AttendanceTypeId == (int)id).OrderBy(x => x.Location);
    }

    protected string RatiosText(Arena.Custom.SECC.Checkin.Entity.Occurrence o)
    {
        if (o.IsRoomClosed)
            return "[room closed]";

        switch (o.RatioStatus)
        {
            case Arena.Custom.SECC.Checkin.Entity.RatioStatus.OverLimit:
                return string.Format("[{0} over]", o.CurrentAttendees - o.PeoplePerLeader * o.CurrentVolunteers);
                break;
            case Arena.Custom.SECC.Checkin.Entity.RatioStatus.CapReached:
                return "[cap reached]";
                break;
            case Arena.Custom.SECC.Checkin.Entity.RatioStatus.RatioReached:
                return "[ratio reached]";
                break;
            case Arena.Custom.SECC.Checkin.Entity.RatioStatus.NotEnoughLeaders:
                return "[too few leaders]";
                break;
            default:
                if (o.Available.HasValue && o.Available.Value < 4)
                    return string.Format("[{0} remaining]", o.Available.Value);
                else
                    return string.Empty;
                break;
        }
    }

    protected bool DisplayRatioCapacity()
    {
        bool isVisible = false;

        if (AttendanceTypeRatio_LookupTypeIDSetting > 0)
            isVisible = true;

        return isVisible;
    }

    protected string GetRatioCapacity(Arena.Custom.SECC.Checkin.Entity.Occurrence o)
    {
        int ratioCapacity = 0;
        string capacityValue = string.Empty;
        if (o.AttendanceTypeRatio != null)
        {
            ratioCapacity = o.CurrentVolunteers * (int)o.AttendanceTypeRatio;
            capacityValue = "(" + ratioCapacity.ToString() + ")";
        }
        else
        {
            capacityValue = "(N/A)";
        }
        
        return capacityValue;
        
    }
    protected bool RatiosTextBold(Arena.Custom.SECC.Checkin.Entity.Occurrence o)
    {
        return !o.IsRoomClosed && (o.RatioStatus == Arena.Custom.SECC.Checkin.Entity.RatioStatus.OverLimit || (o.RatioStatus == Arena.Custom.SECC.Checkin.Entity.RatioStatus.Ok && o.Available.HasValue && o.Available.Value < 4));
    }

    #endregion

    #region Private Methods...

    /// <summary>
    /// Changes the ActiveViewIndex of the MultiView control 'mv' and sets all child controls 
    /// to appropiate values.
    /// </summary>
    /// <param name="viewIndex">Index of which view to display in popup control</param>
    private void ChangePopupView(int viewIndex)
    {
        /// hidden unless told otherwise....
        viewPopupOptions.ActiveViewIndex = 0;
        viewRoomCap.ActiveViewIndex = 0;
        PopupButton1.Visible = true;
        switch (viewIndex) {
            /// View room participants
            case 0:
                mv.ActiveViewIndex = 0;
                viewPopupOptions.ActiveViewIndex = 1;
                PopupButton1.Text = "Refresh";
                PopupButton1.CommandName = "Refresh";
                PopupButton1.OnClientClick = "";

                ShowActiveCheck.Checked = true;
                this.ShowAttendees();

                Occurrence occ = CD.Occurrences.Where(x => x.Id == int.Parse(hfOccurrence.Value)).FirstOrDefault();
                if (occ != null) {
                    OccurrenceLabel.Text = string.Format("{0} {1}", occ.Name, occ.Location);
                    OccurrenceLabel2.Text = string.Format("{0} > {1}", occ.AttendanceTypeCategoryName, occ.AttendanceTypeName);
                    RoomCapLabel.Text = occ.RoomCapacity == 0 ? "&#8734;" : occ.RoomCapacity.ToString();
                    RoomCapLeaderLabel.Text = occ.RoomCapacityIncludeLeaders.HasValue && occ.RoomCapacityIncludeLeaders.Value ? "(with leaders)" : "(without leaders)";

                    if (occ.IsRoomClosed) {
                        dropRoomStatus.SelectedIndex = 2;
                    }
                    else if (occ.IsOccurrenceClosed) {
                        dropRoomStatus.SelectedIndex = 1;
                    }
                    else {
                        dropRoomStatus.SelectedIndex = 0;
                    }
                }

                if (this.OperaGhostSetting == -1 || ((List<Person>)AttendeesList.DataSource).FirstOrDefault(x => x.Id == this.OperaGhostSetting) != null) {
                    lnkIncreaseVol.Visible = false;
                }
                else {
                    lnkIncreaseVol.Visible = true;
                    lnkIncreaseVol.Enabled = true;
                    lnkIncreaseVol.CommandArgument = hfOccurrence.Value;
                }

                mdlPopup.Show();
                break;
            /// Search screen
            case 1:
                mv.ActiveViewIndex = 1;
                SearchList.DataSource = null;
                SearchList.DataBind();
                SearchCriteria.Text = "";
                PopupButton1.Text = "Search";
                PopupButton1.CommandName = "Search";
                PopupButton1.OnClientClick = "";

                mdlPopup.Show();
                break;
            /// Move screen
            case 2:
                mv.ActiveViewIndex = 2;

                    PopupButton1.Text = "Move";
                    PopupButton1.CommandName = "Move";
                    PopupButton1.OnClientClick = "if(!validateMovePerson()) {return false;} return true;";

                break;
            /// Tag reprint screen
            case 3:
                mv.ActiveViewIndex = 3;
                viewPopupOptions.ActiveViewIndex = 2;
                PopupButton1.Visible = false;
                //PopupButton1.OnClientClick = "document.getElementById('objectTag').printWithDialog(); return false;";
                break;
            //Move all in room
            case 4:
                string Source = CD.Occurrences.Where(x => x.Id == int.Parse(hfOccurrence.Value)).FirstOrDefault().Location;
                mv.ActiveViewIndex = 2;
                PopupButton1.Text = "Move";
                PopupButton1.CommandName = "Move Attendees";
                PopupButton1.OnClientClick = "return validateMoveAttendees(\"" + Source + "\");";
                break;
        }
    }

    private void CreateTagDropdown(int occurrenceAttendanceId)
    {
        List<Person> peeps = CD.GetFamilyCheckIns(occurrenceAttendanceId);

        /// Populate tag reprint dropdown
        /// with all tags associated with attendance type
        List<ListItem> items = new List<ListItem>();

        var p = peeps.FirstOrDefault(x => x.OccurrenceAttendanceId == occurrenceAttendanceId);

        var rc = new Arena.Core.OccurrenceTypeReportCollection(p.AttendanceTypeId);

        foreach (Arena.Core.OccurrenceTypeReport r in rc) {
            items.Add(new ListItem(r.ReportPath.Split('/').Last().Replace("_", " "), r.ReportPath));
        }


        /// Populate tag reprint dropdown
        /// with any other additional tags, make sure they're unique
        if (!string.IsNullOrEmpty(this.AdditionalTagsSetting)) {
            var tags = this.AdditionalTagsSetting.Split(',');

            foreach (string str in tags) {
                if (!items.Exists(s => s.Value.ToLower() == str.ToLower()))
                    items.Add(new ListItem(str.Split('/').Last().Replace("_", " "), str));
            }
        }

        tagsSelect.DataTextField = "Text";
        tagsSelect.DataValueField = "Value";
        tagsSelect.DataSource = items.OrderBy(s => s.Text);
        tagsSelect.DataBind();

        if (tagsSelect.Items.Count > 0)
        {
            pnlTag.Visible = true;
            SetLabelPath();
        }
        else
        {
            pnlTag.Visible = false;
        }
    }

    private void ShowOccurrences()
    {
        AttendanceTypeCategories.DataSource = this.GetAttendanceTypeCategories();
        AttendanceTypeCategories.DataBind();

        this.UpdatePanicStatus();
    }

    private void SetMoveAllStatus(int attendees)
    {
        btnMoveAll.Visible = AllowBulkMoveSetting;

        btnMoveAll.Enabled = (attendees > 0);

    }

    private void UpdatePanicStatus()
    {
        if (!string.IsNullOrEmpty(this.PanicTagSetting)) {
            bool pMode = CD.GetPanicMode(int.Parse(this.PanicTagSetting.Split('|').Last()));
            lnkPanic.OnClientClick = "return confirm(\"Are you sure you want to turn panic mode " + (pMode ? "OFF?\");" : "ON?\");");
            lnkPanic.ToolTip = (pMode ? "Disables" : "Enables") + " members with 0000 access to check-in";
            lnkPanic.CommandArgument = (!pMode).ToString();
            lnkPanic.CssClass = pMode ? "panicon" : "panicoff";
        }
    }

    private void ShowAttendees()
    {
        if (mv.ActiveViewIndex == 0 && !string.IsNullOrEmpty(hfOccurrence.Value) && !string.IsNullOrEmpty(hfPopupOpen.Value)) {
            int TotalAttendees = this.AttendeesDataBind();

            SetMoveAllStatus(TotalAttendees);

            if (!string.IsNullOrEmpty(this.GridSortExpression))
                AttendeesList.Sort(this.GridSortExpression, SortDirection.Ascending);
        }
    }

    private void ShowSearchResults()
    {
        string name1 = null, name2 = null, code = null;

        this.SplitSearchQuery(out name1, out name2, out code);

        SearchList.DataSource = CD.SearchAttendees(name1, name2, code);
        SearchList.DataBind();
    }

    private int AttendeesDataBind()
    {
        List<Person> people;
        int GrandTotal = 0;

        if (!ShowActiveCheck.Checked) {
            people = CD.GetAttendees(Convert.ToInt32(hfOccurrence.Value));
        }
        else {
            people = CD.GetAttendees(Convert.ToInt32(hfOccurrence.Value)).Where(x => x.Checkout.Date == new DateTime(1900, 1, 1)).ToList();
        }

        TotalAttendeesLabel.Text = people.Where(x => x.PersonType == Arena.Enums.OccurrenceAttendanceType.Person && x.Checkin >= DateTime.Today && x.Checkout == DateTime.Parse("1/1/1900")).Count().ToString();
        TotalVolunteersLabel.Text = people.Where(x => x.PersonType == Arena.Enums.OccurrenceAttendanceType.Leader && x.Checkin >= DateTime.Today && x.Checkout == DateTime.Parse("1/1/1900")).Count().ToString();
        GrandTotal = people.Where(x => x.Checkin >= DateTime.Today && x.Checkout == DateTime.Parse("1/1/1900")).Count();
        GrandTotalLabel.Text = GrandTotal.ToString();


        AttendeesList.DataSource = people;
        AttendeesList.DataBind();

        return GrandTotal;
    }

    private void UpdateTotalCount()
    {
        /// Check if the Visible Attendance Type Categories is set
        /// if it is, only sum up the totals in those categories - otherwise everything
        if (this.VisibleAttendanceTypeCategories == null) {
            TotalAttendees.Text = CD.Occurrences.Sum(c => c.CurrentAttendees).ToString();
            TotalVolunteers.Text = CD.Occurrences.Sum(c => c.CurrentVolunteers).ToString();
        }
        else {
            TotalAttendees.Text = CD.Occurrences.Where(x => this.VisibleAttendanceTypeCategories.Contains(x.AttendanceTypeCategoryId)).Sum(c => c.CurrentAttendees).ToString();
            TotalVolunteers.Text = CD.Occurrences.Where(x => this.VisibleAttendanceTypeCategories.Contains(x.AttendanceTypeCategoryId)).Sum(c => c.CurrentVolunteers).ToString();
        }
    }

    private void SetLabelPath()
    {
        LabelPath = string.Format("UserControls/Custom/SECC/Checkin/report.ashx?{0},{1},{2}#toolbar=1&navpanes=0&scrollbar=0&view=Fit", tagsSelect.SelectedValue,  dropChild.SelectedValue, base.CurrentOrganization.OrganizationID);
    }

    private void SplitSearchQuery(out string name1, out string name2, out string securityCode)
    {
        name1 = null;
        name2 = null;
        securityCode = null;

        if (SearchByCheckboxList.Items[0].Selected) {
            if (SearchCriteria.Text.Contains(' ')) {
                name1 = SearchCriteria.Text.Split(' ')[0];
                name2 = SearchCriteria.Text.Split(' ')[1];
            }
            else if (SearchCriteria.Text.Contains(',')) {
                name1 = SearchCriteria.Text.Split(',')[0];
                name2 = SearchCriteria.Text.Split(',')[1];
            }
            else {
                name1 = SearchCriteria.Text;
            }
        }

        if (SearchByCheckboxList.Items[1].Selected)
            securityCode = SearchCriteria.Text;
    }

    #endregion
}