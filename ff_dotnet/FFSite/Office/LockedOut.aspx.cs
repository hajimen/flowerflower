using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace FFSite
{
    public partial class LockedOut : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string until = HttpUtility.UrlDecode(Request.QueryString["until"]);
            LockoutUntilLabel.Text = until;
        }
    }
}
