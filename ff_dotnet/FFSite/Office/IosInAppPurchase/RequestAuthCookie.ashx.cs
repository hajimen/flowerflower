using System;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.Text;
using System.Net;
using System.IO;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace FFSite.Office.IosInAppPurchase
{
    /// <summary>
    /// $codebehindclassname$ の概要の説明です
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class RequestAuthCookie : IHttpHandler
    {
        private static readonly string SandboxVerifyServer = "https://sandbox.itunes.apple.com/verifyReceipt";
        private static readonly string VerifyServer = "https://buy.itunes.apple.com/verifyReceipt";

        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public void ProcessRequest(HttpContext context)
        {
            string receipt;
            try
            {
                receipt = context.Request.Form.Get("receipt");
                if (receipt == null)
                {
                    throw new ArgumentException("レシートがありません。");
                }
            }
            catch (Exception e)
            {
                logger.Info("不正なフォーマットのデータを受け取りました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                return;
            }

            logger.Info("認証要求を受け取りました。RequestInfo: " + WebUtil.RequestInfo(context));

            try
            {
                if (!IsVerifyOk(receipt, false) && !IsVerifyOk(receipt, true))
                {
                    logger.Info("不審な認証要求を受け取りました。RequestInfo: " + WebUtil.RequestInfo(context));
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    return;
                }
            }
            catch (Exception e)
            {
                logger.Info("レシートの検証中に例外が発生しました。RequestInfo: " + WebUtil.RequestInfo(context), e);
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                return;
            }

            DataSet.SubscriberRow subscriber = Util.PublishSubscriber(AuthScheme.Web);
            TokenPublisher p = new TokenPublisher(subscriber, DateTime.Now);
            DataSet.TokenRow t;
            try
            {
                t = p.Publish();
            }
            catch (Exception ex)
            {
                logger.Error("認証トークンの発行に失敗しました", ex);
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                return;
            }
            HttpCookie cookie = new HttpCookie(SiteConstant.AuthTokenCookieName, t.Body);
            cookie.Expires = DateTime.MaxValue;
            context.Response.Cookies.Add(cookie);
            
            context.Response.ContentType = "text/plain";
            context.Response.Write("OK");
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        private bool IsVerifyOk(string receipt, bool isSandbox)
        {
            string host;
            if (isSandbox)
            {
                host = SandboxVerifyServer;
            }
            else
            {
                host = VerifyServer;
            }

            JavaScriptSerializer js = new JavaScriptSerializer();

            Dictionary<string, string> toPost = new Dictionary<string, string>();
            toPost["receipt-data"] = receipt;
            string toPostStr = js.Serialize(toPost);

            byte[] postBytes = new ASCIIEncoding().GetBytes(toPostStr);
            HttpWebRequest request = WebRequest.Create(host) as HttpWebRequest;
            request.Method = "POST";
            request.ContentType = "application/json";
            request.ContentLength = postBytes.Length;
            Stream postStream = request.GetRequestStream();
            postStream.Write(postBytes, 0, postBytes.Length);
            postStream.Close();
            HttpWebResponse response = request.GetResponse() as HttpWebResponse;
            StringBuilder sb = new StringBuilder();
            byte[] buf = new byte[8192];
            Stream resStream = response.GetResponseStream();
            string tempString = null;
            int count = 0;
            do
            {
                count = resStream.Read(buf, 0, buf.Length);
                if (count != 0)
                {
                    tempString = Encoding.ASCII.GetString(buf, 0, count);
                    sb.Append(tempString);
                }
            } while (count > 0);
            Dictionary<string, object> responseDic = js.Deserialize<Dictionary<string, object>>(sb.ToString());

            if (responseDic["status"].ToString() != "0")
            {
                logger.Info("レシートのstatusが0ではありません。");
                return false;
            }

            string ss = "";
            foreach (string s in responseDic.Keys)
            {
                ss += s + ", ";
            }

            IDictionary<string, object> receiptDic = responseDic["receipt"] as IDictionary<string, object>;

            ss = "";
            foreach (string s in receiptDic.Keys)
            {
                ss += s + ", ";
            }

            string productId = receiptDic["product_id"].ToString();
            if (productId == null)
            {
                logger.Info("レシートのproduct_idが空です。");
                return false;
            }
            if (!productId.StartsWith(SiteConstant.IosProductIdStartsWith))
            {
                logger.Info("レシートのproduct_idが不正です。レシートのproduct_id：" + productId);
                return false;
            }

            string appBundleId = receiptDic["bid"].ToString();
            if (appBundleId == null)
            {
                logger.Info("レシートのappBundleIdが空です。");
                return false;
            }
            if (appBundleId != SiteConstant.IosAppBundleId)
            {
                logger.Info("レシートのbidが不正です。レシートのbid：" + appBundleId);
                return false;
            }

            string purchaseDateStr = receiptDic["purchase_date"].ToString();
            DateTime transDate = DateTime.SpecifyKind(DateTime.Parse(purchaseDateStr.Replace("Etc/GMT", "")), DateTimeKind.Utc);
            TimeSpan delay = DateTime.UtcNow - transDate;
            if (delay.TotalHours > 24 || delay.TotalHours < -24)
            {
                logger.Info("レシートのpurchase_dateが不正です。レシートのpurchase_date：" + purchaseDateStr);
                return false;
            }

            return true;
        }
    }
}
