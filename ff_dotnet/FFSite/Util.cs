using System;
using System.Configuration;
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
    public class Util
    {
        public static DataSet.SubscriberRow PublishSubscriber(AuthScheme authScheme)
        {
            DataSet.SubscriberDataTable dt = new DataSet.SubscriberDataTable();
            SubscriberTableAdapter ta = new SubscriberTableAdapter();
            dt.AddSubscriberRow(SiteConstant.Title, Guid.NewGuid().ToString("N"), authScheme.ToString(), Constant.Ago);
            ta.Update(dt);
            return dt[0];
        }

        public static DataSet.SubscriberRow ResolveSubscriber(string tokenBody, AuthScheme authScheme)
        {
            if (tokenBody == null)
            {
                return PublishSubscriber(authScheme);
            }
            TokenTableAdapter tta = new TokenTableAdapter();
            DataSet.TokenDataTable tdt = tta.GetDataByBody(tokenBody);
            if (tdt.Count == 0)
            {
                return PublishSubscriber(authScheme);
            }
            DataSet.TokenRow token = tdt[0];
            SubscriberTableAdapter sta = new SubscriberTableAdapter();
            DataSet.SubscriberRow subscriber = sta.GetDataById(token.SubscriberId)[0];
            if (subscriber.AuthScheme != authScheme.ToString())
            {
                throw new DoubtfulAuthBehaviorException("認証トークンが発行されたときとは異なる認証方式で渡されました。");
            }
            return subscriber;
        }
    }
}
