using System;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Net;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using FFCommon.Apns;

namespace FFSite.Office.IosInAppPurchase
{
    public class RequestProcessor
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public RequestProcessor()
        {
        }

        public void Process(string deviceToken, FFCommon.DataSet.SubscriberRow subscriber, bool isEnable)
        {
            APNsTableAdapter ta = new APNsTableAdapter();
            DataSet.APNsDataTable dt = ta.GetDataBySubscriberId(subscriber.Id);
            if (dt.Count > 0)
            {
                if (!isEnable)
                {
                    dt.RemoveAPNsRow(dt[0]);
                    ta.Update(dt);
                }
                return;
            }

            CheckDeviceTokenFormat(deviceToken);

            if (isEnable)
            {
                dt.AddAPNsRow(subscriber, deviceToken, false, 0, false);
                ta.Update(dt);
            }
        }

        private void CheckDeviceTokenFormat(string deviceToken)
        {
            if (deviceToken == null || deviceToken.Length != Notification.DeviceTokenHexLength)
                throw new BadDeviceTokenException(deviceToken);
            byte[] deviceTokenBin = new byte[Notification.DeviceTokenHexLength / 2];
            try
            {
                for (int i = 0; i < deviceTokenBin.Length; i++)
                {
                    deviceTokenBin[i] = byte.Parse(deviceToken.Substring(i * 2, 2), System.Globalization.NumberStyles.HexNumber);
                }
            }
            catch (Exception)
            {
                throw new BadDeviceTokenException(deviceToken);
            }
        }
    }
}
