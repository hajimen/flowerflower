using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using FFCommon;
using FFCommon.Apns;
using System.IO;
using System.Threading;

namespace TestFFCommon.Apns
{
    [TestFixture]
    public class WriterTest : AssertionHelper
    {
        [Test]
        public void TestSimple()
        {
            using (MemoryStream ms = new MemoryStream(1000))
            {
                Archive a = new Archive();
                BlockingQueue<Notification> queue = new BlockingQueue<Notification>();
                Writer w = new Writer(new TConnection(), ms, queue, a);
                w.Close();
            }
        }

        [Test]
        public void TestWrite()
        {
            using (MemoryStream ms = new MemoryStream(1000))
            {
                Archive a = new Archive();
                BlockingQueue<Notification> queue = new BlockingQueue<Notification>();
                Writer w = new Writer(new TConnection(), ms, queue, a);

                Payload p = new Payload();
                p.Badge = 1;
                p.Message = "test";
                p.Sound = "sound.wav";

                queue.Enqueue(new TNotification(0, p, "44F5AE40CC0FFC100A4984D2D949A337B3633B6B266F03674439B2F776A49FD3"));
                Thread.Sleep(100);

                w.Close();

                byte[] buf = ms.ToArray();
                Expect(buf.Length, Is.GreaterThan(50));
            }
        }
    }


    class TConnection : IConnection
    {
        public void Aborting(int identifier)
        {
        }

        public bool SocketConnected
        {
            get { return true; }
        }

        public bool IsClosed
        {
            get { return true; }
        }
    }
}
