using System;
using System.Web;
using System.Collections;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using System.Net;
using FFCommon.Apns;

namespace FFSite.Office.IosApns
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
            string deviceToken;
            try
            {
                deviceToken = context.Request.Form.Get("deviceToken");
                if (deviceToken == null)
                {
                    throw new ArgumentException("デバイストークンがありません。");
                }
            }
            catch (Exception e)
            {
                logger.Info("不正なフォーマットのデータを受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                WebUtil.AddErrorReasonHeader(context, ErrorReason.Malformed);
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                return;
            }

            try
            {
                new RequestProcessor().Process(deviceToken);
                context.Response.StatusCode = (int)HttpStatusCode.OK;
            }
            catch (DoubtfulAuthBehaviorException e)
            {
                logger.Info("不審な認証要求を受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
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
