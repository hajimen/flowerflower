using System;
using System.Collections.Generic;
using System.Text;

namespace FFCommon
{
    public class ApnsException : Exception
    {
        public ApnsException(string message)
            : base(message)
        {
        }
    }
}
