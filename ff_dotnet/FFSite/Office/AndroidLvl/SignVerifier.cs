using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Security.Cryptography;
using System.Text;
using System.Security.Cryptography.X509Certificates;

namespace FFSite.Office.AndroidLvl
{

    // verify RSA SHA-1 digital signing.
    public class SignVerifier
    {
        RSACryptoServiceProvider rsa;

        public SignVerifier(string publicKey_xml)
        {
            rsa = new RSACryptoServiceProvider();
            rsa.FromXmlString(publicKey_xml);
        }

        public bool IsOk(string data, string signature)
        {
            string sha1Oid = CryptoConfig.MapNameToOID("SHA1");
            return rsa.VerifyData(Encoding.ASCII.GetBytes(data), sha1Oid, Convert.FromBase64String(signature));
        }
    }
}
