using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;

namespace FFCommon
{
    public class Constant
    {
        public static readonly string RegistryKeyName = @"SOFTWARE\Kaoriha\flowerflower";
        public static readonly string ApnsCustomDataAuthTokenName = "authToken";
        public static readonly string WatchDogFilename = "watchdog.txt";
        public static readonly string ToNextReleaseFilename = "tonextrelease.txt";
        public static readonly string CatalogueFilename = "catalogue.json";
        public static readonly string CataloguePushMessageKeyName = "push_message";

        public static readonly Random Random = new Random();
        public static readonly RNGCryptoServiceProvider CryptoRandom = new RNGCryptoServiceProvider();
        public static int CryptoRandomInt
        {
            get
            {
                byte[] bs = new byte[4];
                CryptoRandom.GetBytes(bs);
                return BitConverter.ToInt32(bs, 0);
            }
        }
        public static readonly TimeSpan AuthTokenOutdateSpan = new TimeSpan(72, 0, 0);
        public static readonly TimeSpan AuthTokenDoubtLeakSpan = new TimeSpan(24, 0, 0);
        public static readonly TimeSpan AuthTokenLifeSpan = new TimeSpan(120, 0, 0);
        public static readonly int AuthTokenMaxCount = 3;
        public static readonly TimeSpan SubscriberBanSpan = new TimeSpan(96, 0, 0);
        public static readonly TimeSpan NonceExpireSpan = new TimeSpan(0, 5, 0);
        public static readonly DateTime Ago = new DateTime(1970, 1, 1);
        public static readonly TimeSpan UpdateMarginSpan = new TimeSpan(0, 0, 10);
    }
}
