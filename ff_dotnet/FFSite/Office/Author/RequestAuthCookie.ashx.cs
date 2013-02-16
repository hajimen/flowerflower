using System;
using System.Web;
using System.Collections;
using System.Web.Services;
using System.Web.Services.Protocols;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using System.Net;

namespace FFSite.Office.Author
{
    /// <summary>
    /// $codebehindclassname$ の概要の説明です
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class RequestAuthCookie : IHttpHandler
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            string authCode = context.Request.Form.Get("authCode");
            if (authCode == null)
            {
                context.Response.Write("Failed");
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                return;
            }

            SubscriberTableAdapter sta = new SubscriberTableAdapter();
            DataSet.SubscriberDataTable dt = sta.GetDataByAuthKey(authCode);
            if (dt.Count == 0)
            {
                context.Response.Write("Failed");
                context.Response.StatusCode = (int) HttpStatusCode.BadRequest;
                return;
            }
            DataSet.SubscriberRow subscriber = dt[0];
            TokenPublisher p = new TokenPublisher(subscriber, DateTime.Now);
            DataSet.TokenRow token;
            try
            {
                token = p.Publish();
            }
            catch (DoubtfulAuthBehaviorException ex)
            {
                p.LockOut();
                logger.Info(ex.Message);
                context.Response.Write("Failed");
                context.Response.StatusCode = (int) HttpStatusCode.BadRequest;
                return;
            }

            WebUtil.AddAuthCookie(context.Response, token.Body);

            context.Response.StatusCode = (int) HttpStatusCode.OK;
            context.Response.Write("OK");
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}
