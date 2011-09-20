using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Arena.Custom.SECC.Checkin.Attribute;

namespace Arena.Custom.SECC.Checkin.Entity
{
    [Serializable]
    public class Occurrence : IEquatable<Occurrence>
    {
        [ResultColumn(Map = "occurrence_name")]
        public string Name { get; set; }

        [ResultColumn(Map = "occurrence_id")]
        public int Id { get; set; }

        [ResultColumn(Map = "group_id")]
        public int AttendanceTypeCategoryId { get; set; }

        [ResultColumn(Map = "group_name")]
        public string AttendanceTypeCategoryName { get; set; }

        [ResultColumn(Map = "occurrence_type")]
        public int AttendanceTypeId { get; set; }

        [ResultColumn(Map = "type_name")]
        public string AttendanceTypeName { get; set; }

        [ResultColumn(Map = "current_attendees")]
        public int CurrentAttendees { get; set; }

        [ResultColumn(Map = "current_volunteers")]
        public int CurrentVolunteers { get; set; }

        [ResultColumn(Map = "occurrence_start_time")]
        public DateTime StartTime { get; set; }

        [ResultColumn(Map = "occurrence_end_time")]
        public DateTime EndTime { get; set; }

        [ResultColumn(Map = "check_in_start")]
        public DateTime CheckinStartTime { get; set; }

        [ResultColumn(Map = "check_in_end")]
        public DateTime CheckinEndTime { get; set; }

        [ResultColumn(Map = "location_id")]
        public int LocationId { get; set; }

        [ResultColumn(Map = "location")]
        public string Location { get; set; }

        [ResultColumn(Map = "occurrence_closed")]
        public bool IsOccurrenceClosed { get; set; }

        [ResultColumn(Map = "room_closed")]
        public bool IsRoomClosed { get; set; }

        [ResultColumn(Map = "max_people")]
        public int RoomCapacity { get; set; }

        [ResultColumn(Map = "include_leaders_for_max_people")]
        public bool? RoomCapacityIncludeLeaders { get; set; }

        [ResultColumn(Map = "use_room_ratios")]
        public bool UseRoomRatios { get; set; }

        [ResultColumn(Map = "people_per_leader")]
        public int PeoplePerLeader { get; set; }

        [ResultColumn(Map = "min_leaders")]
        public int MinimumLeaders { get; set; }

        [ResultColumn(Map = "type_order")]
        public int AttendanceTypeSortOrder { get; set; }

        [ResultColumn(Map = "occurrence_type_ratio_value")]
        public int? AttendanceTypeRatio { get; set; }


        public RatioStatus RatioStatus
        {
            get
            {
                if (this.RoomCapacity > 0 && (this.RoomCapacityIncludeLeaders.HasValue && this.RoomCapacityIncludeLeaders.Value ? this.RoomCapacity <= this.CurrentAttendees + this.CurrentVolunteers : this.RoomCapacity <= this.CurrentAttendees))
                    return RatioStatus.CapReached;
                else if (this.UseRoomRatios && this.MinimumLeaders > 0 && this.CurrentVolunteers < this.MinimumLeaders)
                    return RatioStatus.NotEnoughLeaders;
                else if (this.UseRoomRatios && this.PeoplePerLeader > 0 && this.CurrentAttendees == this.PeoplePerLeader * this.CurrentVolunteers)
                    return RatioStatus.RatioReached;
                else if (this.UseRoomRatios && this.PeoplePerLeader > 0 && this.CurrentAttendees > this.PeoplePerLeader * this.CurrentVolunteers)
                    return RatioStatus.OverLimit;
                //else if (this.UseRoomRatios && this.CurrentAttendees - this.PeoplePerLeader * this.CurrentVolunteers < 4)
                //    return RatioStatus.Ok;
                else
                    return RatioStatus.Ok;
            }
        }

        /// <summary>
        /// Return the number of available positions kids can check in to.
        /// Returns NULL if infinite.
        /// </summary>
        public int? Available
        {
            get
            {
                int ratioLeft = this.PeoplePerLeader > 0 ? this.PeoplePerLeader * this.CurrentVolunteers - this.CurrentAttendees : int.MaxValue;
                int capLeft = this.RoomCapacity > 0 ? (this.RoomCapacity - (this.RoomCapacityIncludeLeaders.HasValue && this.RoomCapacityIncludeLeaders.Value ? this.CurrentAttendees + this.CurrentVolunteers : this.CurrentAttendees)) : int.MaxValue;
                
                int remaining = Math.Min(ratioLeft, capLeft);

                return (remaining == int.MaxValue ? new int?() : remaining);
            }
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }

        #region IEquatable<Occurrence> Members

        public bool Equals(Occurrence other)
        {
            // Check whether the compared object is null.
            if (Object.ReferenceEquals(other, null)) return false;

            // Check whether the compared object references the same data.
            if (Object.ReferenceEquals(this, other)) return true;

            // Check whether the products' properties are equal.
            return Id.Equals(other.Id);
        }

        #endregion
    }
}
