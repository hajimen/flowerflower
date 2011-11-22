using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Net.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.IO;

namespace FFCommon.Apns
{
    public class Connection : IDisposable
    {
        private X509CertificateCollection certCollection;
        private X509Certificate cert;
        private TcpClient tcpClient;
        private SslStream stream;
        private Service service;

        private bool isClosed = false;
        private Reader reader;
        private Writer writer;

        public Connection(string host, int port, string p12File, string p12FilePassword, BlockingQueue<Notification> queue, Archive archive, Service service)
        {
            this.service = service;

            if (string.IsNullOrEmpty(p12FilePassword))
                cert = new X509Certificate2(System.IO.File.ReadAllBytes(p12File), "", X509KeyStorageFlags.MachineKeySet); // TODO not tested
            else
                cert = new X509Certificate2(System.IO.File.ReadAllBytes(p12File), p12FilePassword, X509KeyStorageFlags.MachineKeySet);
            certCollection = new X509CertificateCollection();
            certCollection.Add(cert);

            tcpClient = new TcpClient(host, port);

            stream = new SslStream(tcpClient.GetStream(), false, new RemoteCertificateValidationCallback(ValidateServerCertificate),
                new LocalCertificateSelectionCallback(SelectLocalCertificate));
            stream.AuthenticateAsClient(host, certCollection, System.Security.Authentication.SslProtocols.Ssl3, false);
            if (!stream.IsMutuallyAuthenticated || !stream.CanWrite)
            {
                throw new Exception();
            }

            reader = new Reader(this, stream, archive);
            writer = new Writer(stream, queue, archive);
        }

        public void Aborting(int identifier)
        {
            service.ConnectionAborting(identifier);
        }

        private bool ValidateServerCertificate(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
        {
            return true;
        }

        private X509Certificate SelectLocalCertificate(object sender, string targetHost, X509CertificateCollection localCertificates,
            X509Certificate remoteCertificate, string[] acceptableIssuers)
        {
            return cert;
        }

        public void Close()
        {
            if (isClosed) return;

            writer.Close();
            stream.Dispose();
            reader.Close();
            tcpClient.Close();

            isClosed = true;
        }

        public void Dispose()
        {
            Close();
        }
    }
}
