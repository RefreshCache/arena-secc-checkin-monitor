using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using Arena.DataLayer;
using Arena.DataLib;
using System.Collections;
using Arena.Custom.SECC.Checkin.Entity;
using System.Data.SqlTypes;
using System.Data.Linq.Mapping;
using System.Reflection;
using Arena.Custom.SECC.Checkin.Attribute;

namespace Arena.Custom.SECC.Checkin.DataLayer
{
    public class CheckinData : SqlData
    {
        private List<Occurrence> _occurrences;

        public List<Occurrence> Occurrences
        {
            get
            {
                if (_occurrences == null)
                {

                    ArrayList paramList = new ArrayList();
                    paramList.Add(new SqlParameter("@lookup_Type_id", _occurrenceTypeRatio_LookupTypeID));

                    DataTable table = base.ExecuteDataTable("cust_SECC_checkin_sp_get_occurrenceActive", paramList);
                    _occurrences = this.ToList<Occurrence>(table);
                }

                return _occurrences;
            }
        }

        private int _occurrenceTypeRatio_LookupTypeID;

        public int OccurrenceTypeRatio_LookupTypeID
        {
            get
            {
                return _occurrenceTypeRatio_LookupTypeID;
            }
            set
            {
                _occurrenceTypeRatio_LookupTypeID = value;
            }
        }

        public DateTime Date = DateTime.Today;

        public CheckinData() { }

        public CheckinData(int otrLookupType)
        {
            _occurrenceTypeRatio_LookupTypeID = otrLookupType;
        }

        public List<Person> GetAttendees(int Id)
        {
            DataTable table;
            ArrayList paramList = new ArrayList();
            paramList.Add(new SqlParameter("@OccurrenceID",Id));
            paramList.Add(new SqlParameter("@AttendanceStatus", 1));

            table = base.ExecuteDataTable("cust_SECC_checkin_sp_get_occurrence_attendanceByOccurrenceID", paramList);

            return this.ToList<Person>(table);
        }

        public List<Person> GetAllActiveAttendees()
        {

            DataTable table = base.ExecuteDataTable("cust_SECC_checkin_sp_get_occurrenceAttendees");

            return this.ToList<Person>(table);
        }

        public List<Person> SearchAttendees(string name1, string name2, string securityCode)
        {
            DataTable table;
            ArrayList paramList = new ArrayList();
            paramList.Add(new SqlParameter("@name1", name1));
            paramList.Add(new SqlParameter("@name2", name2));
            paramList.Add(new SqlParameter("@securityCode", securityCode));
            
            table = base.ExecuteDataTable("cust_SECC_checkin_sp_get_searchActiveAttendees", paramList);

            return this.ToList<Person>(table);
        }

        public List<Person> GetFamilyCheckIns(int occurrenceAttendanceId)
        {
            DataTable table;

            ArrayList paramList = new ArrayList();
            paramList.Add(new SqlParameter("@OccurrenceAttendanceID", occurrenceAttendanceId));
            table = base.ExecuteDataTable("cust_SECC_checkin_sp_get_familyoccurrences",paramList);

            return this.ToList<Person>(table);
        }

        public bool GetPanicMode(int profileID)
        {
            SqlParameter sqlParam = new SqlParameter("@panicMode", SqlDbType.Bit);
            sqlParam.Direction = ParameterDirection.Output;

            try {
                base.ExecuteScalar("cust_SECC_checkin_sp_get_panic", new ArrayList() {
                    new SqlParameter("panicProfileID", profileID),
                    sqlParam
                });

                return (bool)sqlParam.Value;
            }
            catch (SqlException exception) {
                throw exception;
            }

            //return false;
        }

        public void SetPanicMode(int profileID, bool isEnabled)
        {
            try {
                base.ExecuteNonQuery("cust_SECC_checkin_sp_panic",
                    new ArrayList() { 
                        new SqlParameter("enable", isEnabled),
                        new SqlParameter("profileID", profileID) 
                    });
            }
            catch (SqlException exception) {
                throw exception;
            }
        }

        public void SetRoomRatios(int attendanceTypeId, int minLeaders, int peoplePerLeader)
        {
            try
            {
                base.ExecuteNonQuery("cust_SECC_checkin_sp_setroomratios",
                    new ArrayList() { 
                        new SqlParameter("attendanceTypeId", attendanceTypeId),
                        new SqlParameter("minLeaders", minLeaders), 
                        new SqlParameter("peoplePerLeader", peoplePerLeader) });
            }
            catch (SqlException exception)
            {
                throw exception;
            }
        }

        public void SetRoomCap(int locationId, int occurrenceId, int roomCap, bool includeLeaders)
        {
            /// save room cap
            var l = new Arena.Organization.Location(locationId);
            l.MaxPeople = roomCap;
            l.IncludeLeadersForMaxPeople = includeLeaders;
            l.Save("ArenaOz");

            /// Check if we need to close/open the locations occurrences
            /// 
            List<Occurrence> locationOccurences = new List<Occurrence>();
            locationOccurences.AddRange(Occurrences.Where(x => x.LocationId == locationId));

            foreach (Occurrence o in locationOccurences)
            {
                var occurrence = new Arena.Core.Occurrence(o.Id);
                var occtype = occurrence.OccurrenceType;

                if (occtype.UseRoomRatios)
                {
                    if (occtype.MinLeaders != 0 || occtype.PeoplePerLeader != 0)
                        occurrence.PerformRoomRatioActions(Arena.Enums.CheckInAction.CheckIn, "ArenaOz");
                    else
                    {
                        if (OccurrenceShouldBeClosed(roomCap, includeLeaders, occurrence.GetCurrentCount(Enums.OccurrenceAttendanceType.Person), occurrence.GetCurrentCount(Enums.OccurrenceAttendanceType.Leader)))
                            occurrence.OccurrenceClosed = true;
                        else
                            occurrence.OccurrenceClosed = false;
                        occurrence.Save("ArenaOz", false);
                    }
                }
            }

        }

        private bool OccurrenceShouldBeClosed(int roomCap, bool includeLeaders, int attendees, int leaders)
        {
            bool ShouldClose = false;

            if (roomCap > 0)
            {
                if (includeLeaders && (attendees + leaders) >= roomCap)
                    ShouldClose = true;
                else if (!includeLeaders && attendees >= roomCap)
                    ShouldClose = true;
            }

            return ShouldClose;

        }

        public void OpenCloseOccurrence(int occurrenceId, string userId, bool isClosed)
        {
            base.ExecuteNonQuery("cust_SECC_checkin_sp_save_occurrence_status",
                new ArrayList() { 
                        new SqlParameter("OccurrenceID", occurrenceId), 
                        new SqlParameter("UserId", userId), 
                        new SqlParameter("OccurrenceClosed", isClosed) });
        }

        public void OpenCloseRoom(int locationId, string userId, bool isClosed)
        {
            var l = new Arena.Organization.Location(locationId);
            l.RoomClosed = isClosed;
            l.Save(userId);
        }

        public void OpenCloseAllOccurrences(string userID, bool isClosed)
        {
            OpenCloseAllOccurrences(userID, isClosed, null);
        }

        public void OpenCloseAllOccurrences(string userId, bool isClosed, int[] FilteredOccurrenceTypes)
        {
            string FilteredTypes = String.Empty;
            if (FilteredOccurrenceTypes != null)
            {
                for (int i = 0; i < FilteredOccurrenceTypes.Length; i++)
                {
                    if(!(i == (FilteredOccurrenceTypes.Length -1)))
                        FilteredTypes += FilteredOccurrenceTypes[i].ToString() + ",";
                    else
                        FilteredTypes += FilteredOccurrenceTypes[i].ToString();
                }
            }
            base.ExecuteNonQuery("cust_SECC_checkin_sp_save_occurrenceActive",
                new ArrayList() { 
                        new SqlParameter("UserId", userId), 
                        new SqlParameter("OccurrenceClosed", isClosed) ,
                        new SqlParameter("FilteredOccurrences", FilteredTypes)});
        }

        public void Checkout(int occurrenceId, int personId)
        {
            var kiosk = new Arena.CheckIn.Kiosk();
            kiosk.CheckOut(occurrenceId, personId);

            /// If we checked out a leader, check to see if we need to close the occurrence
            var occurrence = new Arena.Core.Occurrence(occurrenceId);
            var occtype = occurrence.OccurrenceType;

            if (occtype.MinLeaders != 0 || occtype.PeoplePerLeader != 0)
                occurrence.PerformRoomRatioActions(Arena.Enums.CheckInAction.CheckOut, "ArenaOz");
        }

        public void ForceReload()
        {
            _occurrences = null;
        }

        public void Checkin(int personId, int occurrenceId, string securityCode, Arena.Enums.OccurrenceAttendanceType occurrenceAttendanceType)
        {
            var kiosk = new Arena.CheckIn.Kiosk();
            kiosk.CheckIn(
                new Arena.Core.Person(personId),
                new Arena.Core.Occurrence(occurrenceId),
                string.Empty,
                -1,
                securityCode,
                occurrenceAttendanceType);

            var occurrence = new Arena.Core.Occurrence(occurrenceId);
            var occtype = occurrence.OccurrenceType;

            if (occtype.MinLeaders != 0 || occtype.PeoplePerLeader != 0)
                occurrence.PerformRoomRatioActions(Arena.Enums.CheckInAction.CheckIn, "ArenaOz");
        }

        public Person GetPersonById(int personId)
        {
            DataTable table;
            int CheckOldIDs = 0;
            ArrayList paramList = new ArrayList() {
                    new SqlParameter("PersonID", personId),
                    new SqlParameter("CheckOldIDs", CheckOldIDs) // Don't check
                };

            table = base.ExecuteDataTable("core_sp_get_personByID", paramList);

            IEnumerable<Person> person =
                (from o in table.AsEnumerable()
                 select new Person()
                 {
                     Id = personId,
                     FullName = o.Field<string>("last_name").Trim() + ", " +
                         ((o.Field<string>("nick_name") != null && (o.Field<string>("nick_name") ?? "").Trim().Length != 0) ?
                             o.Field<string>("nick_name").Trim() :
                             o.Field<string>("first_name").Trim())
                 });

            return person.Count<Person>() != 0 ? person.First<Person>() : null;
        }

        private List<T> ToList<T>(DataTable dataTable)
        {
            List<T> genericList = new List<T>();
            Type t = typeof(T);

            PropertyInfo[] pi = t.GetProperties();

            foreach (DataRow row in dataTable.Rows) {

                object defaultInstance = Activator.CreateInstance(t);

                foreach (PropertyInfo prop in pi) {

                    var a = (ResultColumnAttribute)prop.GetCustomAttributes(typeof(ResultColumnAttribute), false).FirstOrDefault();

                    if (a != null && dataTable.Columns[a.Map] != null) {
                        object columnvalue = row[a.Map];

                        if (columnvalue != null && columnvalue != DBNull.Value) {
                            prop.SetValue(defaultInstance, columnvalue, null);
                        }
                    }
                }

                T myclass = (T)defaultInstance;

                genericList.Add(myclass);
            }

            return genericList;
        }
    }
}