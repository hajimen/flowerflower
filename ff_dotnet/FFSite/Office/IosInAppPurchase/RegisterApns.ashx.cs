using System;
using System.Data;
using System.Web;
using System.Collections;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Net;
using FFCommon.Apns;

namespace FFSite.Office.IosInAppPurchase
{
    /// <summary>
    /// $codebehindclassname$ の概要の説明です
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class RegisterApns : IHttpHandler
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public void ProcessRequest(HttpContext context)
        {
            DateTime now = DateTime.Now;
            string tokenBody = context.Request.Cookies[SiteConstant.AuthTokenCookieName].Value;
            TokenVerifier v = new TokenVerifier(tokenBody, now);
            if (!v.IsValid)
            {
                logger.Info("token invalid. RequestInfo: " + WebUtil.RequestInfo(context));
                WebUtil.HandleForbiddenAccess(context);
                return;
            }

            string deviceToken;
            bool isEnable;
            try
            {
                deviceToken = context.Request.Form.Get("deviceToken");
                if (deviceToken == null)
                {
                    throw new ArgumentException("デバイストークンがありません。");
                }
                string enableStr = context.Request.Form.Get("enable");
                if (enableStr == null)
                {
                    throw new ArgumentException("enableパラメータがありません。");
                }
                isEnable = (enableStr != "false");
            }
            catch (Exception e)
            {
                logger.Info("不正なフォーマットのデータを受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Malformed);
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                return;
            }

            logger.Info("登録要求を受け取りました。RequestInfo: " + WebUtil.RequestInfo(context));
            logger.Info("デバイストークン: " + deviceToken);
            try
            {
                new RequestProcessor().Process(deviceToken, v.Subscriber, isEnable);
                context.Response.StatusCode = (int)HttpStatusCode.OK;
                logger.Info("登録要求は正常に処理されました。RequestInfo: " + WebUtil.RequestInfo(context));
            }
            catch (DoubtfulAuthBehaviorException e)
            {
                logger.Info("不審な登録要求を受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Security);
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
            catch (BadDeviceTokenException e)
            {
                logger.Info("不正なフォーマットのデバイストークンを受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Invalid);
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
            catch (Exception e)
            {
                logger.Info("不明なエラーが発生しました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Invalid);
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
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
