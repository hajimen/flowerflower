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

namespace FFSite
{
    public class AndroidLvlAuthStrategy : AAuthStrategy
    {
        public AndroidLvlAuthStrategy()
            : base(AuthScheme.Android_LVL)
        {
        }
    }
}
