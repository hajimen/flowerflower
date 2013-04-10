using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Security.Principal;
using System.Net;

namespace FFSite
{
    public class AuthModule : IHttpModule
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private AAuthStrategy authStrategy;

        public void context_AuthenticateRequest(Object source, EventArgs e)
        {
            HttpApplication application = (HttpApplication)source;
            HttpContext context = application.Context;

            if (!SiteConstant.IsConfigurationOK)
            {
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                context.Response.End();
                return;
            }

            authStrategy = AuthSchemeUtil.GetAuthStrategy(context.Request.Headers[SiteConstant.AuthSchemeRequestHeaderName]);
            if (!authStrategy.IsAuthRequired(context))
            {
                context.User = new GenericPrincipal(new GenericIdentity("user"), null);
                return;
            }
            authStrategy.AuthenticateRequest(context);
        }

        public void context_EndRequest(Object source, EventArgs e)
        {
            HttpApplication application = (HttpApplication)source;
            HttpContext context = application.Context;
            authStrategy.EndRequest(context);
        }

        public void Init(HttpApplication context)
        {
            context.AuthenticateRequest += this.context_AuthenticateRequest;
//            context.EndRequest += this.context_EndRequest;
        }

        public void Dispose()
        {
        }
    }
}
