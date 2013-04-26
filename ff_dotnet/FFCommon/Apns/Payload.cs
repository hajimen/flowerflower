using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Script.Serialization;

namespace FFCommon.Apns
{
    public class Payload
    {
        private static readonly int maxPayloadSize = 256;
        private int? badge = null;

        public int Badge
        {
            get
            {
                if (badge == null)
                    return 0;
                else
                    return (int)badge;
            }
            set
            {
                badge = value;
            }
        }

        private string sound = null;

        public string Sound
        {
            get { return sound; }
            set
            {
                sound = value;
            }
        }

        private string message = null;

        public string Message
        {
            get { return message; }
            set
            {
                message = value;
            }
        }

        private bool contentAvailable = false;
        public bool ContentAvailable
        {
            get { return contentAvailable; }
            set
            {
                contentAvailable = value;
            }
        }

        private Dictionary<string, object> custom = new Dictionary<string, object>();

        public Dictionary<string, object> Custom
        {
            get { return custom; }
            set
            {
                custom = value;
            }
        }

        public string ToJsonString()
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            Dictionary<string, object> aps = new Dictionary<string, object>();
            if (message != null)
            {
                aps["alert"] = message;
            }
            if (badge != null)
            {
                aps["badge"] = badge;
            }
            if (sound != null)
            {
                aps["sound"] = sound;
            }
            if (contentAvailable)
            {
                aps["content-available"] = 1;
            }

            Dictionary<string, object> root;
            if (custom.Count == 0)
            {
                root = new Dictionary<string, object>();
            }
            else
            {
                root = new Dictionary<string, object>(custom);
            }
            if (message != null || badge != null || sound != null)
            {
                root["aps"] = aps;
            }

            return js.Serialize(root);
        }

        public byte[] ToBytes()
        {
            byte[] result = Encoding.UTF8.GetBytes(ToJsonString());
            if (result.Length > maxPayloadSize)
            {
                throw new TooLongPayloadException();
            }
            return result;
        }
    }

    public class TooLongPayloadException : Exception
    {
    }
}
