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
    public class SiteConstant
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        public static readonly bool IsConfigurationOK;
        private static DataSet.TitleRow title;
        public static DataSet.TitleRow Title
        {
            get { return SiteConstant.title; }
        }
        private static Credential credential;

        public static Credential Credential
        {
            get { return SiteConstant.credential; }
        }
        public static readonly string BadConfigurationPage = "~/Office/BadConfiguration.aspx";
        public static readonly string AskAuthenticationKeyPage = "~/Office/AskAuthenticationKey.aspx";
        public static readonly string LockedOutPage = "~/Office/LockedOut.aspx";
        public static readonly string AuthPagePathContains = "/Auth/";
        public static readonly string AuthTokenCookieName = "flowerflower-AuthToken";
        public static readonly string AuthSchemeRequestHeaderName = "X-flowerflower-AuthScheme";
        public static readonly string AuthTokenRequestResposeHeaderName = "X-flowerflower-AuthToken";
        public static readonly string AuthStatusRequestResposeHeaderName = "X-flowerflower-AuthStatus";
        public static readonly string ErrorReasonResposeHeaderName = "X-flowerflower-ErrorReason";
        public static readonly string MinuteGrainDateTimeFormat = "yyyy年MM月dd日hh時mm分";
        public static readonly int LvlResponseCodeShouldBe;

        private SiteConstant()
        {
        }

        static SiteConstant()
        {
            string title = ConfigurationManager.AppSettings["TitleName"];
            if (title == null)
            {
                logger.Fatal("このサイトのタイトルがweb.configに設定されていません。");
                IsConfigurationOK = false;
                return;
            }

            string lr = ConfigurationManager.AppSettings["LvlResponseCodeShouldBe"];
            if (lr == null || !int.TryParse(lr, out LvlResponseCodeShouldBe))
            {
                logger.Fatal("LvlResponseCodeShouldBeがweb.configに設定されていないか、値が整数ではありません。");
                IsConfigurationOK = false;
                return;
            }

            DataSet.TitleDataTable tdt;
            try
            {
                TitleTableAdapter ta = new TitleTableAdapter();
                tdt = ta.GetDataByName(title);
            }
            catch (Exception e)
            {
                logger.Fatal("データベースにアクセスできません。データベースのアカウントに権限がないか、または接続文字列が間違っています", e);
                IsConfigurationOK = false;
                return;
            }
            if (tdt.Count == 0)
            {
                logger.Fatal("web.configに設定されているこのサイトのタイトルがデータベース上には存在しません。");
                IsConfigurationOK = false;
                return;
            }

            SiteConstant.title = tdt[0];

            credential = new Credential(Title);

            IsConfigurationOK = true;
        }

        public static void TestSettings(DataSet.TitleRow title)
        {
            SiteConstant.title = title;
            SiteConstant.credential = new Credential(Title);
        }
    }
}
