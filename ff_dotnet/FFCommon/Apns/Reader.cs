using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Net;
using System.Threading;

namespace FFCommon.Apns
{
    public class Reader : IDisposable
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private Stream stream;
        private Thread thread;
        private Connection connection;
        private Archive archive;
        private bool isClosed = false;
        public bool IsThreadAlive
        {
            get
            {
                bool result = (thread != null && thread.IsAlive);
                if (!result) logger.Debug("Apns Reader thread has died!");
                return result;
            }
        }

        public Reader(Connection connection, Stream stream, Archive archive)
        {
            this.connection = connection;
            this.stream = stream;
            this.archive = archive;

            thread = new Thread(new ThreadStart(Run));
            thread.Start();
        }

        private void Run()
        {
            byte[] buffer = new byte[6];
            try
            {
                if (stream.Read(buffer, 0, 6) == 6)
                {
                    if (buffer[0] != 8)
                    {
                        throw new NetworkException();
                    }
                    Notification.ErrorStatus errorStatus = (Notification.ErrorStatus)buffer[1];
                    int identifier = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(buffer, 2));
                    archive.Get(identifier).Error(errorStatus);
                    connection.Aborting(identifier);
                }
            }
            catch (IOException)
            {
                // connection closed
            }
        }

        public void Close()
        {
            if (isClosed) return;

            if (!thread.Join(2000))
            {
                thread.Abort();
            }

            isClosed = true;
        }

        public void Dispose()
        {
            Close();
        }
    }

    public class NetworkException : Exception
    {
    }
}
