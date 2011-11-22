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

namespace FFSite.TestPage
{
    public partial class SetupTestToken : System.Web.UI.Page
    {
        private TokenTableAdapter ta = new TokenTableAdapter();
        private DataSet.SubscriberRow subscriber;

        protected void Page_Load(object sender, EventArgs e)
        {
            TitleTableAdapter tta = new TitleTableAdapter();
            DataSet.TitleRow title = tta.GetDataByName("debug title")[0];
            SubscriberTableAdapter sta = new SubscriberTableAdapter();
            DataSet.SubscriberDataTable sdt = sta.GetDataByTitleId(title.Id);
            if (sdt.Count == 0)
            {
                sdt.AddSubscriberRow(title, "debug auth key", AuthScheme.Web.ToString(), Constant.Ago);
                sta.Update(sdt);
            }
            subscriber = sdt[0];
        }

        protected void OutdateButton_Click(object sender, EventArgs e)
        {
            DataSet.TokenRow r = ta.GetDataByBody("debugdeadbeef")[0];
            r.PublishedDate = new DateTime(2000, 1, 1);
            ta.Update(r);
        }

        protected void LivingButton_Click(object sender, EventArgs e)
        {
            DataSet.TokenRow r = ta.GetDataByBody("debugdeadbeef")[0];
            r.PublishedDate = DateTime.Now - Constant.AuthTokenFreshSpan - new TimeSpan(1, 0, 0);
            ta.Update(r);
        }

        protected void FreshButton_Click(object sender, EventArgs e)
        {
            DataSet.TokenRow r = ta.GetDataByBody("debugdeadbeef")[0];
            r.PublishedDate = DateTime.Now - Constant.AuthTokenFreshSpan + new TimeSpan(0, 3, 0);
            ta.Update(r);
        }

        protected void CleanUpButton_Click(object sender, EventArgs e)
        {
            DataSet.TokenDataTable dt = ta.GetData();
            foreach (DataSet.TokenRow r in dt)
            {
                r.Delete();
            }
            ta.Update(dt);

            SubscriberTableAdapter sta = new SubscriberTableAdapter();
            dt.AddTokenRow(subscriber, new DateTime(2000, 1, 1), "debugdeadbeef");
            ta.Update(dt);
            subscriber.LockoutUntil = Constant.Ago;
            sta.Update(subscriber);
        }

        protected void BeforeLockoutButton_Click(object sender, EventArgs e)
        {
            CleanUpButton_Click(sender, e);
            ta.Insert(subscriber.Id, DateTime.Now - new TimeSpan(0, 4, 0), "deadbeef2");
            ta.Insert(subscriber.Id, DateTime.Now - new TimeSpan(0, 3, 0), "deadbeef3");
            /*
            DataSet.TokenRow r = ta.GetDataBySubscriberId(s.Id)[0];
            r.PublishedDate = DateTime.Now - new TimeSpan(0, 5, 0);
            ta.Update(r);
             */
        }
    }
}
