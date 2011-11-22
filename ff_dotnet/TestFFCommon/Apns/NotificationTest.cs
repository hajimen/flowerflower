using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using FFCommon;
using FFCommon.Apns;
using System.IO;

namespace TestFFCommon.Apns
{
    [TestFixture]
    public class NotificationTest : AssertionHelper
    {
        [Test]
        public void TestSimple()
        {
            Payload p = new Payload();
            p.Badge = 1;
            p.Message = "test";
            p.Sound = "sound.wav";

            TNotification n = new TNotification(int.MaxValue, p, "44F5AE40CC0FFC100A4984D2D949A337B3633B6B266F03674439B2F776A49FD3");
            using (MemoryStream ms = new MemoryStream(1000))
            {
                n.Write(0, ms);
                byte[] r = ms.ToArray();

                StringBuilder sb = new StringBuilder();
                for (int i=0;i<r.Length;i++)
                {
                    sb.Append(r[i].ToString("X2"));
                    sb.Append(" ");
                }

                Expect(sb.ToString(), Is.EqualTo("01 00 00 00 00 7F FF FF FF 00 20 44 F5 AE 40 CC 0F FC 10 0A 49 84 D2 D9 49 A3 37 B3 63 3B 6B 26 6F 03 67 44 39 B2 F7 76 A4 9F D3 00 36 7B 22 61 70 73 22 3A 7B 22 61 6C 65 72 74 22 3A 22 74 65 73 74 22 2C 22 62 61 64 67 65 22 3A 31 2C 22 73 6F 75 6E 64 22 3A 22 73 6F 75 6E 64 2E 77 61 76 22 7D 7D "));
            }
        }
    }

    public class TNotification : Notification
    {
        public TNotification(int expiry, Payload payload, string deviceToken) : base(expiry, payload, deviceToken)
        {
        }

        public override void Error(ErrorStatus errorStatus)
        {
            System.Console.WriteLine("TNotification Error status:" + errorStatus.ToString());
        }

        public override void NotSend()
        {
            System.Console.WriteLine("TNotification NotSend");
        }
    }
}
