using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;

using Arena.Portal;
using Arena.Custom.SECC.Checkin.DataLayer;
using Arena.Custom.SECC.Checkin.Entity;
using Arena.Custom.SECC.Checkin.Compare;
using CompArt = ComponentArt.Web.UI;

namespace Arena.Custom.SECC.Checkin {
    public partial class MovePerson : PortalControl
    {

        #region Members

        private Person person;
        protected Person Person {
            get {
                if (person == null)
                    person = CD.GetPersonById(PersonId);
                return person;
            }
            set {
                person = value;
            }
        }
        private int personId;
        public int PersonId {
            get {
                if (personId == null || personId == 0)
                    if (ViewState["personId"] != null)
                        personId = (int)ViewState["personId"];
                return personId;
            }
            set { 
                personId = value;
                ViewState["personId"] = value;
            }
        }

        /// <summary>Source (current) occurrence.</summary>
        private Occurrence sourceOccurrence;
        protected Occurrence SourceOccurrence
        {
            get {
                if (sourceOccurrence == null)
                    sourceOccurrence = GetOccurrenceById(OccurrenceId);
                return sourceOccurrence;
            }
            set {
                sourceOccurrence = value;
            }
        }
        private int sourceOccurrenceId;
        public int OccurrenceId {
            get {
                if (sourceOccurrenceId == null || sourceOccurrenceId == 0)
                    if (ViewState["sourceOccurrenceId"] != null)
                        sourceOccurrenceId = (int)ViewState["sourceOccurrenceId"];
                return sourceOccurrenceId;
            }
            set { 
                sourceOccurrenceId = value;
                ViewState["sourceOccurrenceId"] = value;
            }
        }

        /// <summary>Destination (new) occurrence.</summary>
        //private int destinationOccurrenceId;
        
        /// <summary>Source occurrence attendance record</summary>
        private int occurrenceAttendanceId;
        public int OccurrenceAttendanceId {
            get {
                if (occurrenceAttendanceId == null || occurrenceAttendanceId == 0)
                    if (ViewState["occurrenceAttendanceId"] != null)
                        occurrenceAttendanceId = (int)ViewState["occurrenceAttendanceId"];
                return occurrenceAttendanceId;
            }
            set {
                occurrenceAttendanceId = value;
                ViewState["occurrenceAttendanceId"] = value;
            }
        }

        private Arena.Enums.OccurrenceAttendanceType occurrenceAttendanceType;
        public Arena.Enums.OccurrenceAttendanceType OccurrenceAttendanceType {
            get {
                if (occurrenceAttendanceType == null || occurrenceAttendanceType == 0)
                    if (ViewState["occurrenceAttendanceType"] != null)
                        occurrenceAttendanceType = (Arena.Enums.OccurrenceAttendanceType)ViewState["occurrenceAttendanceType"];
                return occurrenceAttendanceType;
            }
            set {
                occurrenceAttendanceType = value;
                ViewState["occurrenceAttendanceType"] = value;
            }
        }

        private string securityCode;
        public string SecurityCode {
            get {
                if (securityCode == null)
                    if (ViewState["securityCode"] != null)
                        securityCode = (string)ViewState["securityCode"];
                return securityCode;
            }
            set {
                securityCode = value;
                ViewState["securityCode"] = value;
            }
        }

        /// <summary>Checkin data object. Facilitates Arena DB access.</summary>
        private CheckinData cD;
        public CheckinData CD
        {
            get {
                if (cD == null)
                    cD = new Arena.Custom.SECC.Checkin.DataLayer.CheckinData();
                return cD;
            }
            set {
                cD = value;
            }
        }

        public int[] VisibleAttendanceTypeCategories {get; set;}

        /// <summary>
        /// 
        /// </summary>
        private MoveTypes moveType = MoveTypes.Individual;
        public MoveTypes MoveType
        {
            get
            {
                if (moveType == MoveTypes.Individual)
                    if (ViewState["moveType"] != null)
                    {
                        moveType = (MoveTypes)ViewState["moveType"];
                    }
                return moveType;
            }
            set
            {
                moveType = value;
                ViewState["moveType"] = value;
            }
        }

        #endregion

        #region Event Handlers

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                //Initialize
            }
        }

        protected void btnCancel_Clicked(object sender, EventArgs e)
        {
            throw new NotImplementedException();
        }

        private enum DestinationLevel
        {
            AttendanceTypeCat = 0,
            AttendanceType = 1,
            Occurrence = 2
        }

        #endregion

        #region Methods, Private

        private void ShowSourceOccurrence()
        {            

            if (SourceOccurrence != null)
            {
                //Show source occurrence
                lblSourceAttendanceTypeCat.DataBind();
                lblSourceAttendanceType.DataBind();
                lblSourceOccurrence.DataBind();
                lblLocation.DataBind();
                multVwSourceOccurrence.ActiveViewIndex = 0;
            }
            else
            {
                //No occurrence found
                multVwSourceOccurrence.ActiveViewIndex = 1;
            }
        }

        /// <summary>Show destination attendance type categories</summary>
        private void ShowDestination()
        {
            //Initially show top level only (Attendance Type Categories)
            foreach (Occurrence attTypeCat in this.GetAttendanceTypeCategories())
            {
                tvDestinationOccurrence.Nodes.Add(new CompArt.TreeViewNode() {
                    Text = attTypeCat.AttendanceTypeCategoryName.Replace("'", "`"),
                    Value = attTypeCat.AttendanceTypeCategoryId.ToString(),
                    Selectable = true });
            }

            //Default to not selected
            destinationOccurrenceId.Value = "";
            destinationOccurrenceName.Value = "";

        }

        protected void tvDestinationOccurrence_NodeExpanded(object sender, CompArt.TreeViewNodeEventArgs e)
        {

        }

        protected void tvDestinationOccurrence_NodeSelected(object sender, CompArt.TreeViewNodeEventArgs e)
        {

            //Save occurrence id if occurrence was selected
            if (e.Node.Depth == (int)DestinationLevel.Occurrence) {
                destinationOccurrenceId.Value = e.Node.Value;
                destinationOccurrenceName.Value = e.Node.ParentNode.ParentNode.Text +
                    "\\n\\r ' + ' ' + ' " + e.Node.ParentNode.Text + 
                    "\\n\\r ' + ' ' + ' ' + ' ' + ' " + e.Node.Text;
            } else {
                destinationOccurrenceId.Value = "-1";
                destinationOccurrenceName.Value = "";
            }

            //Add children
            if (e.Node.Nodes.Count == 0)
                PopulateChildNodes(e.Node, false);

        }

        private void PopulateChildNodes(CompArt.TreeViewNode parentNode, bool ImmediateChildrenOnly)
        {
            CompArt.TreeViewNode tvNode;
            switch (parentNode.Depth)
            {
                //Attendance type category
                case (int)DestinationLevel.AttendanceTypeCat:   // 0
                    //Add attendance types
                    if (!parentNode.Expanded)
                        foreach (Occurrence attType in GetAttendanceTypes(int.Parse(parentNode.Value)))
                        {
                            //Add attendance type
                            tvNode = new CompArt.TreeViewNode()
                            {
                                Text = attType.AttendanceTypeName,
                                Value = attType.AttendanceTypeId.ToString(),
                                Selectable = true
                            };

                            if (!ImmediateChildrenOnly) {
                                //Add occurrences under attendance type
                                foreach (Occurrence occurrence in GetOccurrences(attType.AttendanceTypeId))
                                {
                                    tvNode.Nodes.Add(new CompArt.TreeViewNode()
                                    {
                                        Text = occurrence.Name + " - " + occurrence.Location,
                                        Value = occurrence.Id.ToString(),
                                        Selectable = true
                                    });
                                }
                                parentNode.Nodes.Add(tvNode);
                            }
                        }
                    break;

                //Attendance type
                case (int)DestinationLevel.AttendanceType:  //1:
                    break;

                //Occurrence
                case (int)DestinationLevel.Occurrence:  //2:
                    break;

                default:
                    break;
            }
        }

        protected IEnumerable<Occurrence> GetAttendanceTypeCategories()
        {
            if (this.VisibleAttendanceTypeCategories == null)
                return CD.Occurrences.Distinct(new AttendanceTypeCategoryComparer()).OrderBy(x => x.AttendanceTypeCategoryName);
            else
                return CD.Occurrences.Distinct(new AttendanceTypeCategoryComparer()).Where(x => this.VisibleAttendanceTypeCategories.Contains(x.AttendanceTypeCategoryId)).OrderBy(x => x.AttendanceTypeCategoryName);
        }

        protected IEnumerable<Occurrence> GetAttendanceTypes(object id)
        {
            return CD.Occurrences.Where(x => x.AttendanceTypeCategoryId == (int)id).Distinct(new AttendanceTypeComparer()).OrderBy(x => x.AttendanceTypeSortOrder);
        }

        protected IEnumerable<Occurrence> GetOccurrences(object id)
        {
            return CD.Occurrences.Where(x => x.AttendanceTypeId == (int)id).OrderBy(x => x.Name).ThenBy(x => x.Location);
        }
        
        protected Occurrence GetOccurrenceById(int OccurrenceId)
        {
            IEnumerable<Occurrence> occurrence = CD.Occurrences.Where(x => x.Id == OccurrenceId);

            return (occurrence.Count<Occurrence>() != 0) ?
                occurrence.First<Occurrence>() : 
                null;
        }

        #endregion

        #region Methods, Public

        /// <summary>Show the control. Set the attributes before calling.</summary>
        public void Show()
        {

            switch (MoveType)
            {
                case MoveTypes.All:
                    if (OccurrenceId == 0)
                        throw new Exception("Error: Can't find the occurrence.");
                    lblPerson.Text = "[All]";
                    ShowSourceOccurrence();
                    ShowDestination();
                    pnlMovePerson.Visible = true;
                    break;
                case MoveTypes.Individual:
                    if (Person == null)
                    {
                        throw new Exception("Error: Can't find the person.");
                    }
                    else
                    {
                        lblPerson.Text = Person.FullName +
                            ((OccurrenceAttendanceType == Arena.Enums.OccurrenceAttendanceType.Leader) ?
                            " (Leader)" : "");
                        ShowSourceOccurrence();
                        ShowDestination();
                        pnlMovePerson.Visible = true;
                    }
                    break;

            }

        }

        /// <summary>Verify that a valid destination occurrence is selected.</summary>
        private bool isOccSelected()
        {
            bool bSelected = true;

            if (int.Parse(tvDestinationOccurrence.SelectedNode.Value) <= 0 ||
                tvDestinationOccurrence.SelectedNode.Depth < (int)DestinationLevel.Occurrence)  //2
            {
                //strError = "Att type cat or att type has been selected. Select an occurrence instead.";
                bSelected = false;
            }

            return bSelected;
        }

        public void Hide()
        {
            pnlMovePerson.Visible = false;
        }

        /// <summary>Move the person from the source occurence to the user-selected occurrence.</summary>
        /// <returns>Success flag.</returns>
        public bool Move(bool bShowConfirm, out string DestinationSecurityCode)
        {
            bool bSuccess = true; DestinationSecurityCode = null;

            if (!isOccSelected()) {
                bSuccess = false;
            } else {
                
                Exception eCheckout = null, eCheckin = null;

                //Check out from the old occurrence.
                try { 
                    bSuccess = Checkout(false); 
                }
                catch (Exception e1) { 
                    eCheckout = e1; 
                } 

                //Check into the new occurrence.
                try
                {
                    CD.Checkin(PersonId, int.Parse(destinationOccurrenceId.Value), SecurityCode, OccurrenceAttendanceType);
                    DestinationSecurityCode = SecurityCode;
                }
                catch (Exception e2)
                {
                    eCheckin = e2;
                    bSuccess = false;
                }

                //Doesn't work when embedded in an AJAX panel
                if (bSuccess && bShowConfirm)
                {
                    //int.Parse(lstDestinationOccurrence.SelectedValue)
                    Occurrence destinationOcc = GetOccurrenceById(int.Parse(destinationOccurrenceId.Value));
                    ScriptManager.RegisterStartupScript(this.Parent, this.Parent.GetType(), "CheckoutComplete", String.Format("alert('{0} {1}has been moved from\n\r{2}\n\r   {3}\n\r      {4}\n\rto\n\r{5}\n\r   {6}\n\r      {7}');",
                        Person.FullName, (OccurrenceAttendanceType == Arena.Enums.OccurrenceAttendanceType.Leader ? "(Leader) " : ""),
                        SourceOccurrence.AttendanceTypeCategoryName, SourceOccurrence.AttendanceTypeName, SourceOccurrence.Name,
                        destinationOcc.AttendanceTypeCategoryName, destinationOcc.AttendanceTypeName, destinationOcc.Name), true);
                }

                //Inform user what part of the move failed.


            }

            return bSuccess;
        }

        public bool MoveRoom(bool showConfirm)
        {
            bool isSuccess = false;                    
            Exception eMove = null;

            if (!isOccSelected())
            {
                isSuccess = false;
                eMove = new Exception("A destination room was not selected.");
            }
            else
            {
                List<Person> Attendees = CD.GetAttendees(SourceOccurrence.Id).Where(x => x.Checkout.Date == new DateTime(1900, 1, 1)).ToList();

                foreach (Person Attendee in Attendees)
                {


                    PersonId = Attendee.Id;
                    try
                    {
                        isSuccess = Checkout(false);
                    }
                    catch (Exception ex)
                    {
                        isSuccess = false;
                        eMove = new Exception("Some moves may have been completed successfully, but an error has occurred when moving " + Attendee.FullName + ".", ex);
                    }

                    if (!isSuccess)
                        break;

                    try
                    {
                        CD.Checkin(personId, int.Parse(destinationOccurrenceId.Value), Attendee.SecurityCode, Attendee.PersonType);
                    }
                    catch (Exception ex1)
                    {
                        isSuccess = false;
                        eMove = new Exception("Some moves may have been completed successfully, but an an error has occurred when moving + " + Attendee.FullName , ex1);

                    }

                    if (!isSuccess)
                        break;
                }
            }

            if (!isSuccess)
            {
                if (eMove != null)
                {
                    throw eMove;
                }
            }
            return isSuccess;

        }


        /// <summary>Check the person out from the source occurence.</summary>
        /// <returns>Success flag.</returns>
        public bool Checkout(bool bShowConfirm)
        {
            bool bSuccess;
            try
            {
                CD.Checkout(OccurrenceId, PersonId);  //(OccurrenceAttendanceId);
                bSuccess = true;
            }
            catch (Exception e)
            {
                //throw new Exception("Couldn't check out.", e);
                throw;
                bSuccess = false;
            }

            //Doesn't work when embedded in an AJAX panel
            if (bSuccess && bShowConfirm)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CheckoutComplete", String.Format("alert('{0} {1}has been checked out from\n\r{2}\n\r   {3}\n\r      {4}');",
                    Person.FullName, (OccurrenceAttendanceType == Arena.Enums.OccurrenceAttendanceType.Leader ? "(Leader) " : ""),
                    SourceOccurrence.AttendanceTypeCategoryName, SourceOccurrence.AttendanceTypeName, SourceOccurrence.Name), true);

            return bSuccess;
        }

        #endregion

    }
}
