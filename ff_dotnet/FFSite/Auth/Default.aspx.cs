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

namespace FFSite.Auth
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Cookies["last_viewed_pathname"] == null)
            {
                Response.Redirect("9dc22e47-3b96-4366-a77d-42059568324e.html");
            }
            else
            {
                Response.Redirect(HttpUtility.UrlDecode(Request.Cookies["last_viewed_pathname"].Value));
            }
        }
    }
}
