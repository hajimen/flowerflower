using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using FFCommon;

namespace TestFFCommon
{
    [TestFixture]
    public class CredentialTest : AssertionHelper
    {
        [Test]
        public void TestEqual()
        {
            Credential c1 = new Credential();
            Credential c2 = new Credential();
            c1.ApnsIsSandbox = c2.ApnsIsSandbox = true;
            c1.ApnsPkcs12FilePassword = c2.ApnsPkcs12FilePassword = "1234";
            c1.ApnsPkcs12FilePath = c2.ApnsPkcs12FilePath = @"C:\test";
            c1.LvlPackageName = c2.LvlPackageName = "org.kaoriha.test";
            c1.LvlRsaKeyValue = c2.LvlRsaKeyValue = "test";
            Expect(c1 == c2, Is.EqualTo(true));
        }
    }
}
