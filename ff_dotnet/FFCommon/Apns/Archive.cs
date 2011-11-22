using System;
using System.Collections.Generic;
using System.Text;

namespace FFCommon.Apns
{
    public class Archive
    {
        private static readonly int saveCount = 1000;
        private Notification[] depot = new Notification[saveCount];
        private int lastIdentifier = -1;

        public int LastIdentifier
        {
            get { return lastIdentifier; }
        }

        public void Put(int identifier, Notification n)
        {
            lock (this)
            {
                depot[identifier % saveCount] = n;
                lastIdentifier = identifier;
            }
        }

        public Notification Get(int identifier)
        {
            lock (this)
            {
                return depot[identifier % saveCount];
            }
        }
    }
}
