using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.IO;

namespace FFCommon.Apns
{
    public class Writer : IDisposable
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private static readonly TimeSpan doubtConnectionTimeoutSpan = new TimeSpan(0, 5, 0);

        private IConnection connection;
        private Stream stream;
        private BlockingQueue<Notification> queue;
        private Archive archive;
        private Thread thread;
        private bool isClosing = false;
        private bool isClosed = false;
        public bool IsThreadAlive
        {
            get
            {
                bool result = (thread != null && thread.IsAlive);
                if (!result) logger.Debug("Apns Writer thread has died!");
                return result;
            }
        }

        public Writer(IConnection connection, Stream stream, BlockingQueue<Notification> queue, Archive archive)
        {
            this.connection = connection;
            this.stream = stream;
            this.queue = queue;
            this.archive = archive;

            thread = new Thread(new ThreadStart(Run));
            thread.Start();
        }

        private void Run()
        {
            int identifier = 0;
            DateTime lastSendTime = DateTime.Now;

            while (true)
            {
                lock (this)
                {
                    if (isClosing) return;
                }

                Notification n = queue.Dequeue();
                if (n == null)
                {
                    return;
                }
                archive.Put(identifier, n);

                try
                {
                    DateTime now = DateTime.Now;
                    n.Write(identifier, stream);
                    if (now - lastSendTime > doubtConnectionTimeoutSpan)
                    {
                        Thread.Sleep(1000);
                    }
                    if (!connection.SocketConnected)
                    {
                        connection.Aborting(identifier - 1);
                        return;
                    }
                    lastSendTime = now;
                }
                catch (IOException)
                {
                    // connection closed
                    return;
                }
                identifier++;
            }
        }

        public void Close()
        {
            if (isClosed) return;

            lock (this)
            {
                isClosing = true;
            }

            if (queue.Count == 0)
            {
                queue.Enqueue(null);
            }

            if (!thread.Join(2000))
            {
                thread.Abort();
            }
            if (queue.Count == 1 && queue.Peek() == null)
            {
                queue.Dequeue();
            }

            isClosed = true;
        }

        public void Dispose()
        {
            Close();
        }
    }
}
