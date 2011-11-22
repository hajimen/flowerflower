using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;

namespace FFSite
{
    public class WebUtil
    {
        public static void AddAuthCookie(HttpResponse response, string tokenBody)
        {
            HttpCookie cookie = new HttpCookie(SiteConstant.AuthTokenCookieName, tokenBody);
            cookie.Expires = DateTime.MaxValue;
            response.Cookies.Add(cookie);
        }

        public static void RedirectToLockout(HttpContext context, DateTime until)
        {
            context.Response.Redirect(SiteConstant.LockedOutPage + "?until="
                + HttpUtility.UrlEncode(until.ToString(SiteConstant.MinuteGrainDateTimeFormat)));
        }

        public static void RedirectToAskAuthPage(HttpContext context)
        {
            context.Response.Redirect(SiteConstant.AskAuthenticationKeyPage + "?from="
                + HttpUtility.UrlEncode(context.Request.Path));
        }

        public static string RequestInfo(HttpContext context)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine();
            sb.AppendLine("Headers:");
            foreach (string n in context.Request.Headers.AllKeys)
            {
                sb.Append(n);
                sb.Append(": ");
                sb.AppendLine(context.Request.Headers[n]);
            }
            sb.AppendLine("UserHostAddress: " + context.Request.UserHostAddress);
            return sb.ToString();
        }

        public static void AddErrorReasonHeader(HttpContext context, ErrorReason reason)
        {
            context.Response.Headers.Add(SiteConstant.ErrorReasonResposeHeaderName, reason.ToString());
        }
    }
}
