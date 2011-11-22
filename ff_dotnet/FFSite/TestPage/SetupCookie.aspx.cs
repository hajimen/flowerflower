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
using FFCommon;

namespace FFSite.TestPage
{
    public partial class SetupCookie : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void CleanUpButton_Click(object sender, EventArgs e)
        {
            HttpCookie cookie = new HttpCookie(SiteConstant.AuthTokenCookieName);
            cookie.Expires = Constant.Ago;
            Response.Cookies.Add(cookie);
        }
    }
}
