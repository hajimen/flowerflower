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

namespace FFSite.Office.AndroidLvl
{
    public class Verifier
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private static readonly SignVerifier SignVerifier = new SignVerifier(SiteConstant.Credential.LvlRsaKeyValue);
        private int nonceShouldBe;
        private long id;
        private string data;
        private string signature;
        private ResponseData responseData;
        private DateTime now;

        public Verifier(long id, string data, string signature, DateTime now)
        {
            this.id = id;
            this.data = data;
            this.signature = signature;
            this.now = now;
        }

        public ResponseData ResponseData
        {
            get { return responseData; }
        }

        public int NonceShouldBe
        {
            get { return nonceShouldBe; }
        }

        public bool IsOK()
        {
            return IsIdOK()
                && IsResponseDataFormatOK()
                && responseData.nonce == nonceShouldBe
                && responseData.responseCode == SiteConstant.LvlResponseCodeShouldBe
                && responseData.packageName == SiteConstant.Credential.LvlPackageName
                && ((!SiteConstant.LvlVerifySign) || SignVerifier.IsOk(data, signature));
        }

        private bool IsIdOK()
        {
            LVLTableAdapter ta = new LVLTableAdapter();
            DataSet.LVLDataTable dt = ta.GetDataById(id);
            if (dt.Count == 0)
            {
                return false;
            }
            if (dt[0].PublishedDate < now - Constant.NonceExpireSpan)
            {
                return false;
            }
            nonceShouldBe = dt[0].Nonce;
            return true;
        }

        private bool IsResponseDataFormatOK()
        {
            try
            {
                responseData = ResponseData.Parse(data);
            }
            catch (Exception e)
            {
                logger.Info("不正なフォーマットのResponseDataを受け取りました。", e);
                return false;
            }
            return true;
        }
    }
}
