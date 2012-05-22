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
    public class TokenPublisher
    {
        private readonly DateTime now;
        private readonly DataSet.SubscriberRow subscriber;

        public TokenPublisher(DataSet.SubscriberRow subscriber, DateTime now)
        {
            this.subscriber = subscriber;
            this.now = now;
        }

        public DataSet.TokenRow Publish()
        {
            TokenTableAdapter ta = new TokenTableAdapter();
            DataSet.TokenDataTable dt = ta.GetDataBySubscriberId(subscriber.Id);
            if (dt.Count > 0)
            {
                if (dt.Count >= Constant.AuthTokenMaxCount)
                {
                    if (dt[1].PublishedDate > now - Constant.AuthTokenDoubtLeakSpan && subscriber.AuthScheme == AuthScheme.Web.ToString())
                    {
                        throw new DoubtfulAuthBehaviorException("短期間に多数の認証トークンの発行を要求されました");
                    }
                }

                DataSet.TokenRow r2 = dt[dt.Count - 1];
                TokenVerifier v = new TokenVerifier(r2, now);
                if (!v.IsUsed)
                {
                    v.Refresh();
                    return r2;
                }
            }

            for (int i = 0; i < dt.Count - Constant.AuthTokenMaxCount + 1; i++)
            {
                dt[i].Delete();
            }
            string tokenBody = Guid.NewGuid().ToString("N");
            DataSet.TokenRow t = dt.AddTokenRow(subscriber, now, tokenBody, false);
            ta.Update(dt);

            return t;
        }

        public void LockOut()
        {
            subscriber.LockoutUntil = now + Constant.SubscriberBanSpan;
            new SubscriberTableAdapter().Update(subscriber);
        }
    }
}
