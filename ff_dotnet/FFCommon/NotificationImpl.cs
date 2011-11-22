using System;
using System.Collections.Generic;
using System.Text;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using FFCommon.Apns;

namespace FFCommon
{
    public class NotificationImpl : Notification
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private long apnsId;

        public NotificationImpl(int expiry, Payload payload, string deviceTokenStr, long apnsId)
            : base(expiry, payload, deviceTokenStr)
        {
            this.apnsId = apnsId;
        }

        public override void Error(ErrorStatus errorStatus)
        {
            switch (errorStatus)
            {
                case ErrorStatus.InvalidToken:
                    {
                        APNsTableAdapter ta = new APNsTableAdapter();
                        ta.UpdateInvalidDeviceToken(apnsId);
                        break;
                    }
                default:
                    logger.Error("APNs returned error:" + errorStatus.ToString() + " APNs id:" + apnsId);
                    break;
            }
        }

        public override void NotSend()
        {
            logger.Error("");
        }
    }
}
