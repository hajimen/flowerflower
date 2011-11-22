using System;
using System.Collections.Generic;
using System.Text;
using FFCommon.Apns;

namespace FFCommon
{
    abstract public class ANotificationService : IDisposable
    {
        abstract public void Close();

        abstract public void Dispose();

        abstract public void Enqueue(Notification n);
    }

    class NotificationServiceImpl : ANotificationService
    {
        private Service service;

        public NotificationServiceImpl(bool sandbox, string p12File, string p12FilePassword)
        {
            service = new Service(sandbox, p12File, p12FilePassword);
        }

        override public void Close()
        {
            service.Close();
        }

        override public void Dispose()
        {
            service.Dispose();
        }

        override public void Enqueue(Notification n)
        {
            service.Enqueue(n);
        }
    }
}
