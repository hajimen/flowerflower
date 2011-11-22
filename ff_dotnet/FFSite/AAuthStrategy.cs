using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace FFSite
{
    abstract public class AAuthStrategy
    {
        abstract public void AuthenticateRequest(HttpContext context);
        abstract public void EndRequest(HttpContext context);
        protected DateTime now;

        protected AAuthStrategy()
        {
            now = DateTime.Now;
        }

        public bool IsAuthRequired(HttpContext context)
        {
            return context.Request.Path.Contains(SiteConstant.AuthPagePathContains);
        }
    }
}
