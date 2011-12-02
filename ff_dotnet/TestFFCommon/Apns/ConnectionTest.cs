using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using FFCommon;
using FFCommon.Apns;

namespace TestFFCommon.Apns
{
    [TestFixture]
    public class ConnectionTest : AssertionHelper
    {
        [Test]
        public void TestSimple()
        {
            using (Connection c = new Connection("gateway.sandbox.push.apple.com", 2195, SecureConstant.P12File, SecureConstant.P12FilePassword, new BlockingQueue<Notification>(),
                new Archive(), new Service(true, SecureConstant.P12File, SecureConstant.P12FilePassword)))
            {
                c.Close();
            }
        }
    }
}
