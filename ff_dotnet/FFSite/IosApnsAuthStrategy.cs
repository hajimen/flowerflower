using System;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Net;
using System.Security.Principal;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace FFSite
{
    public class IosApnsAuthStrategy : AAuthStrategy
    {
        public IosApnsAuthStrategy()
            : base(AuthScheme.iOS_APNs)
        {
        }
    }
}
