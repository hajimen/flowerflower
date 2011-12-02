using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;

namespace FFCommon.Apns
{
    public class Service : IDisposable
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static readonly string sandboxHost = "gateway.sandbox.push.apple.com";
        private static readonly string productHost = "gateway.push.apple.com";
        private static readonly int port = 2195;

        private bool isSandbox;
        private string p12File;
        private string p12FilePassword;

        private Thread thread;
        private BlockingQueue<Notification> queue = new BlockingQueue<Notification>();
        private Connection connection = null;
        private Archive archive;
        private bool isConnectionAborting = false;
        private int errorNotificationIdentifier;
        private bool isClosing = false;
        private bool isClosed = false;

        public Service(bool isSandbox, string p12File, string p12FilePassword)
        {
            this.isSandbox = isSandbox;
            this.p12File = p12File;
            this.p12FilePassword = p12FilePassword;

            if (connection != null)
            {
                throw new InvalidOperationException("Service already started");
            }

            Connect();

            thread = new Thread(new ThreadStart(Run));
            thread.Start();
        }

        private void Connect()
        {
            isConnectionAborting = false;
            archive = new Archive();
            string host;
            if (isSandbox)
                host = sandboxHost;
            else
                host = productHost;
            connection = new Connection(host, port, p12File, p12FilePassword, queue, archive, this);
        }

        public void Enqueue(Notification n)
        {
            if (!connection.IsThreadAlive) logger.Debug("Apns Connection thread has died!");
            if (thread == null || !thread.IsAlive) logger.Debug("Apns Service thread has died!");
            queue.Enqueue(n);
        }

        private void Run()
        {
            logger.Debug("Service.Run start");
            lock (this)
            {
                while (true)
                {
                    while (!isConnectionAborting && !isClosing)
                    {
                        Monitor.Wait(this);
                    }
                    if (isClosing)
                    {
                        logger.Debug("Service.Run exit");
                        return;
                    }

                    connection.Close();
                    connection = null;
                    if (archive.LastIdentifier != -1)
                    {
                        for (int i = errorNotificationIdentifier + 1; i <= archive.LastIdentifier; i++)
                        {
                            queue.Enqueue(archive.Get(i));
                        }
                    }
                    Connect();
                    logger.Debug("Service.Run Connection reconnect");
                }
            }
        }

        public virtual void ConnectionAborting(int identifier)
        {
            lock (this)
            {
                isConnectionAborting = true;
                errorNotificationIdentifier = identifier;
                Monitor.Pulse(this);
            }
        }

        public void Close()
        {
            if (isClosed) return;

            lock (this)
            {
                isClosing = true;
                Monitor.Pulse(this);
            }
            if (!thread.Join(2000))
            {
                thread.Abort();
            }

            if (connection != null)
            {
                connection.Close();
                connection = null;
                while (queue.Count > 0)
                {
                    Notification n = queue.Dequeue();
                    n.NotSend();
                }
            }

            isClosed = true;
        }

        public void Dispose()
        {
            Close();
        }
    }
}
