using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.IO;
using System.Reflection;

namespace OnboardingOffboarding.Util
{

    public static class IEnumerableExtensions
    {

        /// <summary>
        /// Gets a comma-separated values (CSV) formatted string from a given enumerable list of objects.  Uses reflection to output all publicly writable properties of the object type.
        /// </summary>
        /// <typeparam name="T">Object type found in the IEnumerable list</typeparam>
        /// <param name="list">The list of objects to output to CSV</param>
        /// <returns>A string containing comma-separated values (CSV) formatting for the given list of objects</returns>
        public static string GetCSV<T>(this IEnumerable<T> list, bool includeReadOnlyProperties, bool includeHeader)
        {
            StringBuilder csvbuilder = new StringBuilder();
            list.WriteCSV(new StringWriter(csvbuilder), includeReadOnlyProperties, includeHeader);
            return csvbuilder.ToString();
        }

        /// <summary>
        /// Writes to a TextWriter comma-separated values (CSV) formatted output from a given enumerable list of objects.  Uses reflection to output all publicly writable properties and fields of the object type.
        /// </summary>
        /// <typeparam name="T">Object type found in the IEnumerable list</typeparam>
        /// <param name="list">The list of objects to output to CSV</param>
        /// <param name="writer">The TextWriter to write the comma-separated values (CSV) output to</param>
        public static void WriteCSV<T>(this IEnumerable<T> list, TextWriter writer, bool includeReadOnlyProperties, bool includeHeader)
        {
            // Export ALL fields with public writable property/field reflection
            // skips properties with the [XmlIgnore] attribute
            var memberList = from member in typeof(T).GetMembers(BindingFlags.Public | BindingFlags.Instance)
                             where
                                (member is FieldInfo
                                    || (member is PropertyInfo
                                        && (includeReadOnlyProperties || (member as PropertyInfo).CanWrite)
                                        )
                                    )
                                && member.GetCustomAttributes(typeof(System.Xml.Serialization.XmlIgnoreAttribute), true).Length == 0
                             select member;
            if (includeHeader)
            {
                int i = 0;
                foreach (var member in memberList)
                {
                    if (i++ > 0)
                    {
                        writer.Write(',');
                    }
                    writer.Write(member.Name);
                }
                if (i == 0)
                {
                    return;
                }
                writer.WriteLine();
            }
            else if (memberList.Count() == 0)
            {
                return;
            }
            foreach (var item in list)
            {
                int x = 0;
                foreach (var member in memberList)
                {
                    if (x++ > 0)
                    {
                        writer.Write(',');
                    }
                    writer.Write('"');
                    object value = member is FieldInfo ?
                        (member as FieldInfo).GetValue(item) :
                        (member as PropertyInfo).GetValue(item, null);
                    if (value != null)
                    {
                        writer.Write(value.ToString().Replace("\"", "\"\""));
                    }
                    writer.Write('"');
                }
                writer.WriteLine();
            }
        }


        public static IEnumerable<object> memberList { get; set; }
    }

}