using System;
using System.Collections.Generic;
using System.Text;

namespace FFSite
{
    public enum AuthScheme
    {
        Android_LVL,
        iOS_APNs,
        Web
    }

    public class AuthSchemeUtil
    {
        public static AAuthStrategy GetAuthStrategy(string authScheme)
        {
            if (authScheme != null)
            {
                if (authScheme == AuthScheme.Android_LVL.ToString())
                {
                    return new AndroidLvlAuthStrategy();
                }
                if (authScheme == AuthScheme.iOS_APNs.ToString())
                {
                    return new IosApnsAuthStrategy();
                }
            }
            return new WebAuthStrategy();
        }
    }
}
