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
    abstract public class AAuthStrategy
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        protected DateTime now;
        protected readonly AuthScheme authScheme;

        protected AAuthStrategy(AuthScheme authScheme)
        {
            now = DateTime.Now;
            this.authScheme = authScheme;
        }

        public bool IsAuthRequired(HttpContext context)
        {
            return context.Request.Path.Contains(SiteConstant.AuthPagePathContains);
        }

        virtual public void AuthenticateRequest(HttpContext context)
        {
            HttpStatusCode code = AuthenticateRequestImpl(context);
            if (code != HttpStatusCode.OK)
            {
                context.Response.StatusCode = (int)code;
                context.Response.End();
                return;
            }
        }

        virtual public void EndRequest(HttpContext context)
        {
        }

        public HttpStatusCode AuthenticateRequestImpl(HttpContext context)
        {
            string tokenBody = context.Request.Headers[SiteConstant.AuthTokenRequestResposeHeaderName];
            if (tokenBody == null)
            {
                logger.Info("認証トークンのないリクエストがありました。RequestInfo: " + WebUtil.RequestInfo(context));
                return HttpStatusCode.Forbidden;
            }

            logger.Info("token:" + tokenBody + " RequestInfo:" + WebUtil.RequestInfo(context));
            TokenVerifier v = new TokenVerifier(tokenBody, now);
            if (!v.IsValid)
            {
                logger.Info("token invalid. RequestInfo: " + WebUtil.RequestInfo(context));
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Invalid);
                return HttpStatusCode.BadRequest;
            }
            if (!v.IsAuthScheme(authScheme))
            {
                logger.Info("scheme is not " + authScheme.ToString() + ". RequestInfo: " + WebUtil.RequestInfo(context));
                return HttpStatusCode.Forbidden;
            }
            if (v.IsLockedOut)
            {
                logger.Info("subscriber is locked out. RequestInfo: " + WebUtil.RequestInfo(context));
                WebUtil.AddErrorReasonHeader(context, ErrorReason.LockedOut);
                return HttpStatusCode.BadRequest;
            }

            if (!v.IsLiving)
            {
                logger.Info("token is not living. RequestInfo: " + WebUtil.RequestInfo(context));
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Invalid);
                return HttpStatusCode.BadRequest;
            }

            if (v.IsOutdated)
            {
                logger.Info("token is Outdated. RequestInfo: " + WebUtil.RequestInfo(context));
                context.Response.Headers[SiteConstant.AuthStatusRequestResposeHeaderName] = "Outdated";
            }
            if (!v.IsUsed)
            {
                v.SetUsed();
            }

            if (v.IsAuthScheme(AuthScheme.iOS_APNs))
            {
                APNsTableAdapter ata = new APNsTableAdapter();
                DataSet.APNsDataTable adt = ata.GetDataBySubscriberId(v.Subscriber.Id);
                if (adt[0].UnreadRelease > 0)
                {
                    adt[0].UnreadRelease = 0;
                    ata.Update(adt);
                }
            }

            context.User = new GenericPrincipal(new GenericIdentity("user"), null);
            return HttpStatusCode.OK;
        }
    }
}
