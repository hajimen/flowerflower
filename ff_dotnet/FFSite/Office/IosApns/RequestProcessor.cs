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

namespace FFSite.Office.IosApns
{
    public class RequestProcessor
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public RequestProcessor()
        {
        }

        public void Process(string deviceToken)
        {
            APNsTableAdapter ta = new APNsTableAdapter();
            DataSet.APNsDataTable dt = ta.GetDataByDeviceToken(deviceToken, SiteConstant.Title.Id);
            DataSet.SubscriberRow subscriber;
            if (dt.Count == 0)
            {
                logger.Info("new subscriber: deviceToken:" + deviceToken);
                CheckDeviceTokenFormat(deviceToken);
                subscriber = Util.PublishSubscriber(AuthScheme.iOS_APNs);
                dt.AddAPNsRow(subscriber, deviceToken, false, 0, false);
                ta.Update(dt);
            }
            else
            {
                DataSet.APNsRow apns = dt[0];
                if (apns.Failed)
                {
                    apns.Failed = false;
                    ta.Update(apns);
                }
                SubscriberTableAdapter sta = new SubscriberTableAdapter();
                subscriber = sta.GetDataById(apns.SubscriberId)[0];
                logger.Info("refresh token: deviceToken:" + deviceToken + " subscriber id:" + subscriber.Id);
            }
            TokenPublisher tp = new TokenPublisher(subscriber, DateTime.Now);
            DataSet.TokenRow token = tp.Publish();
            logger.Info("token: deviceToken:" + deviceToken + " tokenBody:" + token.Body);
            ApnsPusher pusher = ApnsPusher.GetInstance(SiteConstant.Title);
            pusher.PushToken(subscriber, token.Body);
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
