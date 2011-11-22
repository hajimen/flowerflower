using System;
using System.Collections.Generic;
using System.Text;
using System.Net;

namespace FFCommon.Apns
{
    public abstract class Notification
    {
        public static readonly int DeviceTokenHexLength = 64;
        private static readonly byte tokenLength = 32;
        private int expiry; // 2038îNñ‚ëËÅI
        private Payload payload;
        private byte[] deviceToken;

        public Notification(int expiry, Payload payload, string deviceTokenStr)
        {
            if (deviceTokenStr.Length != tokenLength * 2)
            {
                throw new ArgumentException("deviceToken is bad length");
            }
            deviceToken = new byte[tokenLength];
            for (int i = 0; i < tokenLength; i++)
            {
                deviceToken[i] = byte.Parse(deviceTokenStr.Substring(i * 2, 2), System.Globalization.NumberStyles.HexNumber);
            }
            this.expiry = expiry;
            this.payload = payload;
        }

        public abstract void Error(ErrorStatus errorStatus);
        public enum ErrorStatus
        {
            Nothing = 0,
            Processing = 1,
            NoDeviceToken = 2,
            NoTopic = 3,
            NoPayload = 4,
            InvalidTokenSize = 5,
            InvalidTopicSize = 6,
            InvalidPayloadSize = 7,
            InvalidToken = 8,
            Unknown = 255
        }

        public abstract void NotSend();

        public void Write(int identifier, System.IO.Stream stream)
        {
            byte[] buffer;

            // Command
            stream.WriteByte(1);

            // Identifier
            buffer = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(identifier));
            stream.Write(buffer, 0, buffer.Length);

            // Expiry
            buffer = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(expiry));
            stream.Write(buffer, 0, buffer.Length);

            // Token length
            stream.WriteByte(0);
            stream.WriteByte(tokenLength);

            // Device token
            stream.Write(deviceToken, 0, tokenLength);

            // Payload length
            buffer = payload.ToBytes();
            stream.WriteByte(0);
            stream.WriteByte((byte) buffer.Length);

            // Payload
            stream.Write(buffer, 0, buffer.Length);
        }
    }
}
