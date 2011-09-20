using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Linq.Expressions;
using System.Web.UI.WebControls;
using System.Collections;

namespace Arena.Custom.SECC.Checkin.Sort
{
    public class GenericSorter<T, PT>
    {
        public IEnumerable<T> Sort(IEnumerable source, string sortExpression, SortDirection sortDir)
        {
            var param = Expression.Parameter(typeof(T), "item");

            var sortLambda = Expression.Lambda<Func<T, PT>>(Expression.Convert(Expression.Property(param, sortExpression), typeof(PT)), param);

            if (sortDir == SortDirection.Ascending)
                return source.OfType<T>().AsQueryable<T>().OrderBy<T, PT>(sortLambda);
            else
                return source.OfType<T>().AsQueryable<T>().OrderByDescending<T, PT>(sortLambda);
        }

        public IEnumerable<T> Sort(IEnumerable<T> source, string sortExpression, SortDirection sortDir)
        {
            var param = Expression.Parameter(typeof(T), "item");

            var sortLambda = Expression.Lambda<Func<T, PT>>(Expression.Convert(Expression.Property(param, sortExpression), typeof(PT)), param);

            if (sortDir == SortDirection.Ascending)
                return source.AsQueryable<T>().OrderBy<T, PT>(sortLambda);
            else
                return source.AsQueryable<T>().OrderByDescending<T, PT>(sortLambda);
        }
    }
}
