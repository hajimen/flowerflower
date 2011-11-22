using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using FFCommon;
using FFCommon.Apns;
using System.Threading;

namespace TestFFCommon.Apns
{
    [TestFixture]
    public class ServiceTest : AssertionHelper
    {
        [Test]
        public void TestSimple()
        {
            TService s = new TService(true, SecureConstant.P12File, SecureConstant.P12FilePassword);

            Payload p = new Payload();
            p.Badge = 1;
            p.Message = "test";

            Notification n = new TNotification(int.MaxValue, p, "44F5AE40CC0FFC100A4984D2D949A337B3633B6B266F03674439B2F776A49FD3"); // valid token
            s.Enqueue(n);

            Thread.Sleep(5000);
            Expect(s.isAborted, Is.EqualTo(false));

            Notification n2 = new TNotification(int.MaxValue, p, "D4D9B50237423A48633F05F74FED2132BB49A1833565EE580E321E5A6A18DE95"); // invalid token
            p.Message = "test2";
            Notification n3 = new TNotification(int.MaxValue, p, "44F5AE40CC0FFC100A4984D2D949A337B3633B6B266F03674439B2F776A49FD3");
            s.Enqueue(n2);
            s.Enqueue(n3);

            Thread.Sleep(5000);
            Expect(s.isAborted, Is.EqualTo(true));

            s.Close();
        }
    }

    public class TService : Service
    {
        public bool isAborted = false;

        public TService(bool isSandbox, string p12File, string p12FilePassword)
            : base(isSandbox, p12File, p12FilePassword)
        {
        }

        public override void ConnectionAborting(int identifier)
        {
            base.ConnectionAborting(identifier);
            isAborted = true;
        }
    }
}
