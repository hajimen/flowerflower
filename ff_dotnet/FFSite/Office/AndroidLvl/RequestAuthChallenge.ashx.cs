using System;
using System.Web;
using System.Collections;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.IO;
using System.Text;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace FFSite.Office.AndroidLvl
{
    /// <summary>
    /// Android LVLに必要なnonceを与えます。
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    public class RequestAuthChallenge : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            int nonce = Constant.CryptoRandomInt;
            DataSet.LVLDataTable dt = new DataSet.LVLDataTable();
            dt.AddLVLRow(nonce, DateTime.Now);
            LVLTableAdapter ta = new LVLTableAdapter();
            ta.Update(dt);
            
            AuthChallenge c = new AuthChallenge(dt[0].Id, nonce);
            context.Response.ContentType = "application/json";

            DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(AuthChallenge));
            serializer.WriteObject(context.Response.OutputStream, c);
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }

    [DataContract]
    public class AuthChallenge
    {
        private int nonce;
        private long id;

        [DataMember(Name = "id")]
        public long Id
        {
            get { return id; }
            set { id = value; }
        }

        [DataMember(Name = "nonce")]
        public int Nonce
        {
            get { return nonce; }
            set { nonce = value; }
        }

        public AuthChallenge(long id, int nonce)
        {
            this.id = id;
            this.nonce = nonce;
        }
    }
}
