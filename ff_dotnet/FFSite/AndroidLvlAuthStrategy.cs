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
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        override public void AuthenticateRequest(HttpContext context)
        {
            if (!AuthenticateRequestImpl(context))
            {
                context.Response.StatusCode = (int)HttpStatusCode.Forbidden;
                context.Response.End();
                return;
            }
        }

        private bool AuthenticateRequestImpl(HttpContext context)
        {
            string tokenBody = context.Request.Headers[SiteConstant.AuthTokenRequestResposeHeaderName];
            if (tokenBody == null)
            {
                logger.Info("認証トークンのないリクエストがありました。RequestInfo: " + WebUtil.RequestInfo(context));
                return false;
            }

            TokenVerifier v = new TokenVerifier(tokenBody, now);
            if (!v.IsValid)
            {
                return false;
            }
            if (!v.IsAuthScheme(AuthScheme.Android_LVL))
            {
                return false;
            }
            if (v.IsLockedOut)
            {
                return false;
            }
            if (!v.IsLiving)
            {
                return false;
            }
            if (v.IsOutdated)
            {
                context.Response.Headers[SiteConstant.AuthStatusRequestResposeHeaderName] = "Outdated";
            }
            context.User = new GenericPrincipal(new GenericIdentity("user"), null);
            return true;
        }

        override public void EndRequest(HttpContext context)
        {
        }
    }
}
