using System;
using System.Collections.Generic;
using System.Text;
using FFCommon.DataSetTableAdapters;
using FFCommon.Apns;

namespace FFCommon
{
    public class ApnsPusher
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private static Dictionary<long, ApnsPusher> InstanceDictionary = new Dictionary<long, ApnsPusher>();
 
        private readonly long id;
        private readonly string titleName;
        private readonly Credential credential;
        private readonly ANotificationService service;

        private ApnsPusher(DataSet.TitleRow title)
        {
            CredentialTableAdapter cta = new CredentialTableAdapter();

            this.id = title.Id;
            this.titleName = title.Name;
            this.credential = new Credential(title);

            service = Settings.NewNotificationService(credential.ApnsIsSandbox, credential.ApnsPkcs12FilePath, credential.ApnsPkcs12FilePassword);
        }

        ~ApnsPusher()
        {
            service.Close();
            service.Dispose();
        }

        public static ApnsPusher GetInstance(DataSet.TitleRow title)
        {
            if (InstanceDictionary.ContainsKey(title.Id))
            {
                ApnsPusher ins = InstanceDictionary[title.Id];
                Credential c = new Credential(title);
                if (ins.credential != c)
                {
                    ins.service.Close();
                    ins.service.Dispose();

                    ins = new ApnsPusher(title);
                    InstanceDictionary[title.Id] = ins;
                }
                return ins;
            }
            else
            {
                ApnsPusher ins = new ApnsPusher(title);
                InstanceDictionary[title.Id] = ins;
                return ins;
            }
        }

        public void PushReleaseNotification(string msg)
        {
            APNsTableAdapter ta = new APNsTableAdapter();
            DataSet.APNsDataTable apnsTable = ta.GetDataByTitleId(id);

            foreach (DataSet.APNsRow apnsRow in apnsTable)
            {
                if (apnsRow.Failed || apnsRow.Invalid)
                {
                    continue;
                }
                apnsRow.UnreadRelease++;
                Payload p = new Payload();
                p.Message = msg;
                p.Badge = apnsRow.UnreadRelease;
                p.Custom["titleId"] = titleName;
                p.ContentAvailable = false;
                Notification n = new NotificationImpl(int.MaxValue, p, apnsRow.DeviceToken, apnsRow.Id);
                service.Enqueue(n);
            }

            ta.Update(apnsTable);
        }

        public void PushToken(DataSet.SubscriberRow subscriber, string tokenBody)
        {
            APNsTableAdapter ta = new APNsTableAdapter();
            DataSet.APNsDataTable dt = ta.GetDataBySubscriberId(subscriber.Id);
            if (dt.Count == 0)
            {
                throw new ArgumentException("APNsÇ…Ç»Ç¢SubscriberÇìnÇ≥ÇÍÇ‹ÇµÇΩÅB");
            }
            DataSet.APNsRow apns = dt[0];
            Payload p = new Payload();
            p.Custom[Constant.ApnsCustomDataAuthTokenName] = new object[] { tokenBody };
            Notification n = new NotificationImpl(int.MaxValue, p, apns.DeviceToken, apns.Id);
            service.Enqueue(n);
        }
    }
}
