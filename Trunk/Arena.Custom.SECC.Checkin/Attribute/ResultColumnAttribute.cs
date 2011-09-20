using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Arena.Custom.SECC.Checkin.Attribute
{
    [System.AttributeUsage(System.AttributeTargets.Property)]
    public class ResultColumnAttribute : System.Attribute
    {
        public string Map;

        public ResultColumnAttribute() { }

        public ResultColumnAttribute(string map)
        {
            Map = map;
        }
    }
}
