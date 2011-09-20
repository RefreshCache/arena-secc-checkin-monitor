using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
//using System.Data.Linq.Mapping;
using Arena.Custom.SECC.Checkin.Attribute;

namespace Arena.Custom.SECC.Checkin.Entity
{
    [Serializable]
    public class Person
    {
        [ResultColumn(Map = "person_id")]
        public int Id { get; set; }

        [ResultColumn(Map = "check_in_time")]
        public DateTime Checkin { get; set; }

        [ResultColumn(Map = "check_out_time")]
        public DateTime Checkout { get; set; }

        [ResultColumn(Map = "security_code")]
        public string SecurityCode { get; set; }

        [ResultColumn(Map = "notes")]
        public string Notes { get; set; }

        [ResultColumn(Map="occurrence_attendance_id")]
        public int OccurrenceAttendanceId { get; set; }

        [ResultColumn(Map = "person_guid")]
        public Guid PersonGuid { get; set; }

        [ResultColumn(Map = "full_name")]
        public string FullName { get; set; }

        [ResultColumn(Map = "type")]
        public Arena.Enums.OccurrenceAttendanceType PersonType { get; set; }

        [ResultColumn(Map = "birth_date")]
        public DateTime BirthDate { get; set; }

        [ResultColumn(Map = "occurrence_id")]
        public int OccurrenceId { get; set; }

        [ResultColumn(Map = "occurrence_name")]
        public string OccurrenceName { get; set; }

        [ResultColumn(Map = "occurrence_type")]
        public int AttendanceTypeId { get; set; }

        [ResultColumn(Map = "type_name")]
        public string AttendanceTypeName { get; set; }

        [ResultColumn(Map="location")]
        public string Location { get; set; }

        [ResultColumn(Map = "system_name")]
        public string SystemName { get; set; }

        [ResultColumn(Map = "system_id")]
        public int? SystemId { get; set; }
    }
}
