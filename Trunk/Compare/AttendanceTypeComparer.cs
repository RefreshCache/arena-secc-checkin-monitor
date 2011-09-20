using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Arena.Custom.SECC.Checkin.Compare
{
    public class AttendanceTypeComparer : IEqualityComparer<Arena.Custom.SECC.Checkin.Entity.Occurrence>
    {
        // Products are equal if their names and product numbers are equal.
        public bool Equals(Arena.Custom.SECC.Checkin.Entity.Occurrence x, Arena.Custom.SECC.Checkin.Entity.Occurrence y)
        {

            // Check whether the compared objects reference the same data.
            if (Object.ReferenceEquals(x, y)) return true;

            // Check whether any of the compared objects is null.
            if (Object.ReferenceEquals(x, null) || Object.ReferenceEquals(y, null))
                return false;

            // Check whether the products' properties are equal.
            return x.AttendanceTypeId == y.AttendanceTypeId;
        }

        // If Equals() returns true for a pair of objects,
        // GetHashCode must return the same value for these objects.

        public int GetHashCode(Arena.Custom.SECC.Checkin.Entity.Occurrence x)
        {
            // Check whether the object is null.
            if (Object.ReferenceEquals(x, null)) return 0;

            return x.AttendanceTypeId;
        }
    }
}
