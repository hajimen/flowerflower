using System;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Security.Principal;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using System.Net;

namespace FFSite
{
    public class WebAuthStrategy : AAuthStrategy
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public WebAuthStrategy()
            : base(AuthScheme.Web)
        {
        }

        override public void AuthenticateRequest(HttpContext context)
        {
            if (context.Request.Cookies[SiteConstant.AuthTokenCookieName] == null)
            {
                if (context.Request.Path.EndsWith(".html"))
                {
                    WebUtil.RedirectToAskAuthPage(context);
                }
                else
                {
                    logger.Info("no auth cookie request. RequestInfo: " + WebUtil.RequestInfo(context));
                    context.Response.StatusCode = (int)HttpStatusCode.Forbidden;
                    context.Response.End();
                }
                return;
            }
            string tokenBody = context.Request.Cookies[SiteConstant.AuthTokenCookieName].Value;
            TokenVerifier v = new TokenVerifier(tokenBody, now);
            if (!v.IsValid)
            {
                logger.Info("token invalid. RequestInfo: " + WebUtil.RequestInfo(context));
                WebUtil.RedirectToAskAuthPage(context);
                return;
            }
            if (v.IsLockedOut)
            {
                logger.Info("token is locked out. RequestInfo: " + WebUtil.RequestInfo(context));
                WebUtil.RedirectToLockout(context, v.Subscriber.LockoutUntil);
                return;
            }
            if (v.IsOutdated)
            {
                logger.Info("token is Outdated. RequestInfo: " + WebUtil.RequestInfo(context));
                TokenPublisher p = new TokenPublisher(v.Subscriber, now);
                DataSet.TokenRow t;
                try
                {
                    t = p.Publish();
                }
                catch (DoubtfulAuthBehaviorException e)
                {
                    p.LockOut();
                    logger.Info(e.Message);
                    WebUtil.RedirectToLockout(context, v.Subscriber.LockoutUntil);
                    return;
                }
                catch (Exception ex)
                {
                    logger.Error("認証トークンの発行に失敗しました", ex);
                    context.Response.StatusCode = (int) HttpStatusCode.InternalServerError;
                    context.Response.End();
                    return;
                }
                HttpCookie cookie = new HttpCookie(SiteConstant.AuthTokenCookieName, t.Body);
                cookie.Expires = DateTime.MaxValue;
                context.Response.Cookies.Add(cookie);
            }
            if (!v.IsUsed)
            {
                v.SetUsed();
            }

            context.User = new GenericPrincipal(new GenericIdentity("user"), null);
        }
    }
}
