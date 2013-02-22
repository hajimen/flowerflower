using System;
using System.Web;
using System.Collections;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.IO;
using System.Text;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using System.Net;

namespace FFSite.Office.AndroidLvl
{
    /// <summary>
    /// $codebehindclassname$ の概要の説明です
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class RequestAuthToken : IHttpHandler
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public void ProcessRequest(HttpContext context)
        {
            if (!ProcessRequestImpl(context))
            {
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                return;
            }
        }

        private bool ProcessRequestImpl(HttpContext context)
        {
            long id;
            string data, signature;
            try
            {
                string idstr = context.Request.Form["id"];
                if (idstr == null || !long.TryParse(idstr, out id))
                {
                    throw new ArgumentException("id is null or not number");
                }
                data = context.Request.Form["data"];
                if (data == null)
                {
                    throw new ArgumentException("data is null");
                }
                signature = context.Request.Form["signature"];
                if (signature == null)
                {
                    throw new ArgumentException("signature is null");
                }
            }
            catch (Exception e)
            {
                logger.Info("不正なフォーマットのデータを受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Malformed);
                return false;
            }

            Verifier v = new Verifier(id, data, signature, DateTime.Now);
            if (!v.IsOK())
            {
                logger.Info("不正なデータによる認証要求を受け取りました。RequestInfo: " + WebUtil.RequestInfo(context));
                logger.Info("data:" + data + " signature:" + signature);
                logger.Info("nonce should be:" + v.NonceShouldBe.ToString() + " packageName should be:" + SiteConstant.Credential.LvlPackageName + " responseCode should be:" + SiteConstant.LvlResponseCodeShouldBe.ToString());
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Invalid);
                return false;
            }

            DataSet.TokenRow token;
            try
            {
                DataSet.SubscriberRow subscriber = Util.ResolveSubscriber(context.Request.Headers[SiteConstant.AuthTokenRequestResposeHeaderName], AuthScheme.Android_LVL);
                TokenPublisher tp = new TokenPublisher(subscriber, DateTime.Now);
                token = tp.Publish();
            }
            catch (DoubtfulAuthBehaviorException e)
            {
                logger.Info("不審な認証要求を受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Security);
                return false;
            }

            context.Response.StatusCode = (int)HttpStatusCode.OK;
            context.Response.Headers.Add(SiteConstant.AuthTokenRequestResposeHeaderName, token.Body);

            return true;
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
