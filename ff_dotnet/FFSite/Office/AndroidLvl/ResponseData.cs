using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace FFSite.Office.AndroidLvl
{
    // com.android.vending.licensing.ResponseData�̈ڐA
    public class ResponseData
    {
        // Server response codes.
        public static readonly int LICENSED = 0x0;
        public static readonly int NOT_LICENSED = 0x1;
        public static readonly int LICENSED_OLD_KEY = 0x2;
        public static readonly int ERROR_NOT_MARKET_MANAGED = 0x3;
        public static readonly int ERROR_SERVER_FAILURE = 0x4;
        public static readonly int ERROR_OVER_QUOTA = 0x5;
        public static readonly int ERROR_CONTACTING_SERVER = 0x101;
        public static readonly int ERROR_INVALID_PACKAGE_NAME = 0x102;
        public static readonly int ERROR_NON_MATCHING_UID = 0x103;

        public int responseCode;
        public int nonce;
        public string packageName;
        public string versionCode;
        public string userId;
        public long timestamp;

        /** Response-specific data. */
        public string extra;

        /**  * Parses response string into ResponseData.  
         * 
         * @param responseData response data string  
         * @throws IllegalArgumentException upon parsing error
         * @return ResponseData object  */
        public static ResponseData Parse(string responseData)
        {
            // Must parse out main response data and response-specific data.  
            string[] mainExtraData = responseData.Split(':');
            if (mainExtraData.Length == 0)
            {
                throw new ArgumentException("Blank response.");
            }
            string mainData = mainExtraData[0];

            // Response-specific (extra) data is optional.
            string extraData = "";
            if (mainExtraData.Length > 1)
            {
                extraData = mainExtraData[1];
            }

            string[] fields = mainData.Split('|');
            if (fields.Length < 6)
            {
                throw new ArgumentException("Wrong number of fields.");
            }
            ResponseData data = new ResponseData();
            data.extra = extraData;
            data.responseCode = int.Parse(fields[0]);
            data.nonce = int.Parse(fields[1]);
            data.packageName = fields[2];
            data.versionCode = fields[3];
            // Application-specific user identifier.
            data.userId = fields[4];
            data.timestamp = long.Parse(fields[5]);
            return data;
        }

        override public string ToString()
        {
            return string.Join("|", new string[] { responseCode.ToString(), nonce.ToString(), packageName, versionCode, userId, timestamp.ToString() });
        }
    }
}
