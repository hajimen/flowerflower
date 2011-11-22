using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using FFCommon;
using FFCommon.Apns;

namespace TestFFCommon.Apns
{
    [TestFixture]
    public class PayloadTest : AssertionHelper
    {
        [Test]
        public void TestSimple()
        {
            Payload p = new Payload();
            Expect(p.ToJsonString(), Is.EqualTo("{}"));

            p.Badge = 1;
            p.Message = "test";
            p.Sound = "sound.wav";
            Expect(p.ToJsonString(), Is.EqualTo("{\"aps\":{\"alert\":\"test\",\"badge\":1,\"sound\":\"sound.wav\"}}"));

            p.Custom["custom"] = "custom value";
            Expect(p.ToJsonString(), Is.EqualTo("{\"custom\":\"custom value\",\"aps\":{\"alert\":\"test\",\"badge\":1,\"sound\":\"sound.wav\"}}"));

            string t = "";
            for (int i = 0; i < 16; i++)
            {
                t += "abcdefghabcdefgh";
            }
            p.Custom["toolong"] = t;
            try
            {
                p.ToBytes();
            }
            catch (TooLongPayloadException)
            {
                // ok
                return;
            }
            Assert.Fail("should be exception");

        }
    }
}
