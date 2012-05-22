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
        public enum ErrorReason
        {
            Invalid, LockedOut
        }
        public static readonly string MinuteGrainDateTimeFormat = "yyyy�NMM��dd��hh��mm��";
        public static readonly int LvlResponseCodeShouldBe;

        private SiteConstant()
        {
        }

        static SiteConstant()
        {
            string title = ConfigurationManager.AppSettings["TitleName"];
            if (title == null)
            {
                logger.Fatal("���̃T�C�g�̃^�C�g����web.config�ɐݒ肳��Ă��܂���B");
                IsConfigurationOK = false;
                return;
            }

            string lr = ConfigurationManager.AppSettings["LvlResponseCodeShouldBe"];
            if (lr == null || !int.TryParse(lr, out LvlResponseCodeShouldBe))
            {
                logger.Fatal("LvlResponseCodeShouldBe��web.config�ɐݒ肳��Ă��Ȃ����A�l�������ł͂���܂���B");
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
                logger.Fatal("�f�[�^�x�[�X�ɃA�N�Z�X�ł��܂���B�f�[�^�x�[�X�̃A�J�E���g�Ɍ������Ȃ����A�܂��͐ڑ������񂪊Ԉ���Ă��܂�", e);
                IsConfigurationOK = false;
                return;
            }
            if (tdt.Count == 0)
            {
                logger.Fatal("web.config�ɐݒ肳��Ă��邱�̃T�C�g�̃^�C�g�����f�[�^�x�[�X��ɂ͑��݂��܂���B");
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
