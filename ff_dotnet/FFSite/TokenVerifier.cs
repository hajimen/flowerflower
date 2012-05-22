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
    public class TokenVerifier
    {
        public bool IsValid
        {
            get { return subscriber != null; }
        }

        public bool IsLockedOut
        {
            get
            {
                return subscriber.LockoutUntil >= now;
            }
        }

        public bool IsOutdated
        {
            get
            {
                return token.PublishedDate < now - Constant.AuthTokenOutdateSpan;
            }
        }

        public bool IsLiving
        {
            get
            {
                return token.PublishedDate > now - Constant.AuthTokenLifeSpan;
            }
        }

        public bool IsUsed
        {
            get
            {
                return token.Used;
            }
        }

        private readonly DataSet.SubscriberRow subscriber;

        public DataSet.SubscriberRow Subscriber
        {
            get { return subscriber; }
        }

        private readonly DataSet.TokenRow token;

        public DataSet.TokenRow Token
        {
            get { return token; }
        } 

        private readonly DateTime now;

        private static DataSet.TokenRow GetToken(string tokenBody)
        {
            TokenTableAdapter tta = new TokenTableAdapter();
            DataSet.TokenDataTable tdt = tta.GetDataByBody(tokenBody);
            if (tdt.Count == 1)
            {
                return tdt[0];
            }
            else
            {
                return null;
            }
        }

        public TokenVerifier(string tokenBody, DateTime now) : this(GetToken(tokenBody), now)
        {
        }

        public TokenVerifier(DataSet.TokenRow token, DateTime now)
        {
            this.now = now;
            if (token == null)
            {
                subscriber = null;
                return;
            }

            this.token = token;
            SubscriberTableAdapter sta = new SubscriberTableAdapter();
            DataSet.SubscriberDataTable sdt = sta.GetDataById(token.SubscriberId);
            subscriber = sdt[0];
            if (subscriber.TitleId != SiteConstant.Title.Id)
            {
                subscriber = null;
            }
        }

        public bool IsAuthScheme(AuthScheme authScheme)
        {
            return subscriber.AuthScheme == authScheme.ToString();
        }

        public void Refresh()
        {
            TokenTableAdapter tta = new TokenTableAdapter();
            token.PublishedDate = now;
            tta.Update(token);
        }

        public void SetUsed()
        {
            TokenTableAdapter tta = new TokenTableAdapter();
            token.Used = true;
            tta.Update(token);
        }
    }
}
