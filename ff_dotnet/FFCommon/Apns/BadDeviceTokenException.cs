using System;
using System.Collections.Generic;
using System.Text;

namespace FFCommon.Apns
{
    public class BadDeviceTokenException : Exception
    {
        public BadDeviceTokenException(string message) : base(message)
        {
        }
    }
}
