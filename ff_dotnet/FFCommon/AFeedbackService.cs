using System;
using System.Collections.Generic;
using System.Text;
using JdSoft.Apple.Apns.Feedback;

namespace FFCommon
{
    abstract public class AFeedbackService : IDisposable
    {
        abstract public void Dispose();

        abstract public void Run();

        public abstract event FeedbackService.OnError Error;
        public abstract event FeedbackService.OnFeedback Feedback;
    }

    class FeedbackServiceImpl : AFeedbackService
    {
        private FeedbackService service;
        public FeedbackServiceImpl(bool sandbox, string pkcs12FilePah, string pkcs12FilePassword)
        {
            service = new FeedbackService(sandbox, pkcs12FilePah, pkcs12FilePassword);
        }

        public override void Dispose()
        {
            service.Dispose();
        }

        public override void Run()
        {
            service.Run();
        }

        public override event FeedbackService.OnError Error
        {
            add { service.Error += value; }
            remove { service.Error -= value; }
        }

        public override event FeedbackService.OnFeedback Feedback
        {
            add { service.Feedback += value; }
            remove { service.Feedback -= value; }
        }
    }
}
