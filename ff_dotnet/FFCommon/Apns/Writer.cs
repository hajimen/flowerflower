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
        private Stream stream;
        private BlockingQueue<Notification> queue;
        private Archive archive;
        private Thread thread;
        private bool isClosing = false;
        private bool isClosed = false;

        public Writer(Stream stream, BlockingQueue<Notification> queue, Archive archive)
        {
            this.stream = stream;
            this.queue = queue;
            this.archive = archive;

            thread = new Thread(new ThreadStart(Run));
            thread.Start();
        }

        private void Run()
        {
            int identifier = 0;

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
                    n.Write(identifier, stream);
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
