using System;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace FFSite
{
    public partial class AskAuthenticationKey : System.Web.UI.Page
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Info("RequestInfo: " + WebUtil.RequestInfo(Context));
        }

        protected void OKButton_Click(object sender, EventArgs e)
        {
            SubscriberTableAdapter sta = new SubscriberTableAdapter();
            DataSet.SubscriberDataTable dt = sta.GetDataByAuthKey(AuthenticationKeyTextBox.Text);
            if (dt.Count == 0)
            {
                InvalidKeyLabel.Text = "入力された認証キーは無効です。";
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
                WebUtil.RedirectToLockout(Context, subscriber.LockoutUntil);
                return;
            }
            WebUtil.AddAuthCookie(Response, token.Body);

            if (Request.QueryString["from"] != null && Request.QueryString["from"].Length > 0)
            {
                Response.Redirect(HttpUtility.UrlDecode(Request.QueryString["from"]));
            }
        }
    }
}
