using System;
using System.Collections.Generic;
using System.Text;
using FFCommon;
using JdSoft.Apple.Apns.Feedback;

namespace TestFFCommon
{
    public class FeedbackServiceStub : AFeedbackService
    {
        public FeedbackServiceStub(bool sandbox, string pkcs12FilePah, string pkcs12FilePassword)
        {
        }

        public override void Dispose()
        {
        }

        public override void Run()
        {
        }

        public override event FeedbackService.OnError Error
        {
            add {}
            remove {}
        }

        public override event FeedbackService.OnFeedback Feedback
        {
            add {}
            remove {}
        }
    }
}
