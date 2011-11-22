using System;
using System.Collections.Generic;
using System.Text;
using FFCommon;
using FFCommon.Apns;

namespace TestFFCommon
{
    public class NotificationServiceStub : ANotificationService
    {
        public NotificationServiceStub(bool sandbox, string p12File, string p12FilePassword)
        {
        }

        override public void Close()
        {
        }

        override public void Dispose()
        {
        }

        override public void Enqueue(Notification n)
        {
        }
    }
}
