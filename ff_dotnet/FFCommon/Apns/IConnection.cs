using System;
using System.Collections.Generic;
using System.Text;

namespace FFCommon.Apns
{
    public interface IConnection
    {
        void Aborting(int identifier);
        bool SocketConnected
        {
            get;
        }
        bool IsClosed
        {
            get;
        }
    }
}
