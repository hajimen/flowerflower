using System;
using System.Collections.Generic;
using System.Text;
using log4net.Core;
using System.Xml;
using log4net.Util;

namespace FFCommon
{
    public class Log4netChainsawLayout : log4net.Layout.XmlLayoutSchemaLog4j
    {
        override protected void FormatXml(XmlWriter writer, LoggingEvent loggingEvent)
        {
            if (loggingEvent.Properties["hostname"] == null)
            {
                loggingEvent.Properties["hostname"] = SystemInfo.HostName;
            }
            base.FormatXml(writer, loggingEvent);
        }
    }
}
