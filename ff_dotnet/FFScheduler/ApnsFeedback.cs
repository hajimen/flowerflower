using System;
using System.Collections.Generic;
using System.Text;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using JdSoft.Apple.Apns.Feedback;

namespace FFScheduler
{
    public class ApnsFeedback
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private DataSet.TitleRow title;
        private AFeedbackService service;
        private APNsTableAdapter ta = new APNsTableAdapter();

        public ApnsFeedback(DataSet.TitleRow title)
        {
            this.title = title;
            Credential c = new Credential(title);

            service = Settings.NewFeedbackService(c.ApnsIsSandbox, c.ApnsPkcs12FilePath, c.ApnsPkcs12FilePassword);
            service.Feedback += service_Feedback;
            service.Error += service_Error;
        }

        public void Run()
        {
            service.Run();
        }

        private void service_Feedback(object sender, Feedback feedback)
        {
            ta.UpdateFailedDeviceToken(feedback.DeviceToken, title.Id, 0);
        }

        private void service_Error(object sender, Exception ex)
        {
            logger.Error("APNs FeedbackService error", ex);
        }
    }
}
