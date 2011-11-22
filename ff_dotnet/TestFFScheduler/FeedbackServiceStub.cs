using System;
using System.Collections.Generic;
using System.Text;
using FFCommon;
using JdSoft.Apple.Apns.Feedback;

namespace TestFFScheduler
{
    class FeedbackServiceStub : AFeedbackService
    {
        private event FeedbackService.OnFeedback feedback;

        public FeedbackServiceStub(bool sandbox, string pkcs12FilePah, string pkcs12FilePassword)
        {
        }

        public override void Dispose()
        {
        }

        public override void Run()
        {
            Feedback f = new Feedback();
            f.DeviceToken = "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef";
            f.Timestamp = DateTime.Now;
            feedback(this, f);
        }

        public override event FeedbackService.OnError Error
        {
            add {}
            remove {}
        }

        public override event FeedbackService.OnFeedback Feedback
        {
            add { feedback += value; }
            remove { feedback -= value; }
        }
    }
}
