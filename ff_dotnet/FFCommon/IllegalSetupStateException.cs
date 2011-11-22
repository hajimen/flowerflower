using System;
using System.Collections.Generic;
using System.Text;

namespace FFCommon
{
    public class IllegalSetupStateException : Exception
    {
        public IllegalSetupStateException(string message) : base(message)
        {
        }
    }
}
