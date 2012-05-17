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

            logger.Info("token:" + tokenBody + " RequestInfo:" + WebUtil.RequestInfo(context));
            TokenVerifier v = new TokenVerifier(tokenBody, now);
            if (!v.IsValid)
            {
                logger.Info("token invalid. RequestInfo: " + WebUtil.RequestInfo(context));
                return false;
            }
            if (!v.IsAuthScheme(AuthScheme.iOS_APNs))
            {
                logger.Info("scheme is not APNs. RequestInfo: " + WebUtil.RequestInfo(context));
                // return false;
            }
            if (v.IsLockedOut)
            {
                logger.Info("token is locked out. RequestInfo: " + WebUtil.RequestInfo(context));
                // return false;
            }
            if (!v.IsLiving)
            {
                logger.Info("token is not living. RequestInfo: " + WebUtil.RequestInfo(context));
                // return false;
            }
            if (v.IsOutdated)
            {
                logger.Info("token is Outdated. RequestInfo: " + WebUtil.RequestInfo(context));
                context.Response.Headers[SiteConstant.AuthStatusRequestResposeHeaderName] = "Outdated";
            }
            
            APNsTableAdapter ata = new APNsTableAdapter();
            DataSet.APNsDataTable adt = ata.GetDataBySubscriberId(v.Subscriber.Id);
            if (adt[0].UnreadRelease > 0)
            {
                adt[0].UnreadRelease = 0;
                ata.Update(adt);
            }

            context.User = new GenericPrincipal(new GenericIdentity("user"), null);
            return true;
        }

        override public void EndRequest(HttpContext context)
        {
        }
    }
}
