using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;
using System.IO;
using NUnit.Framework;
using FFSite;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace TestFFSite
{
    [TestFixture]
    public class TokenVerifierTest : AssertionHelper
    {
        string basePath = Path.GetFullPath(@"..\..\unittest");

        [SetUp]
        public void SetUp()
        {
        }

        [TearDown]
        public void TearDown()
        {
        }

        [Test]
        public void Test_Properties()
        {
            using (TransactionScope scope = new TransactionScope())
            {
                TitleTableAdapter tta = new TitleTableAdapter();
                tta.Insert("test title", "test push message", basePath + @"\copyDirectory_dist", basePath + @"\copyDirectory_orig");
                DataSet.TitleRow title = tta.GetDataByName("test title")[0];

                SubscriberTableAdapter sta = new SubscriberTableAdapter();
                sta.Insert(title.Id, "test authkey", "web", Constant.Ago);
                sta.Insert(title.Id, "test authkey 2", "web", new DateTime(2011, 10, 13));
                DataSet.SubscriberDataTable sdt = sta.GetDataByTitleId(title.Id);
                DataSet.SubscriberRow s1, s2;
                if (sdt[0].AuthenticationKey == "test authkey")
                {
                    s1 = sdt[0];
                    s2 = sdt[1];
                }
                else
                {
                    s2 = sdt[0];
                    s1 = sdt[1];
                }

                TokenTableAdapter kta = new TokenTableAdapter();
                kta.Insert(s1.Id, new DateTime(2011, 10, 12, 0, 0, 0), "deadbeef");
                kta.Insert(s2.Id, new DateTime(2011, 10, 12, 4, 59, 50), "deadbeef2");

                Expect(SiteConstant.IsConfigurationOK, Is.EqualTo(true));

                DateTime now = new DateTime(2011, 10, 12, 5, 0, 0);
                TokenVerifier v = new TokenVerifier("deadbeef", now);
                Expect(v.IsValid, Is.EqualTo(true));
                Expect(v.IsLockedOut, Is.EqualTo(false));
                Expect(v.IsOutdated, Is.EqualTo(false));
                Expect(v.IsFresh, Is.EqualTo(false));

                TokenVerifier v2 = new TokenVerifier("no such token", now);
                Expect(v2.IsValid, Is.EqualTo(false));

                TokenVerifier v3 = new TokenVerifier("deadbeef2", now);
                Expect(v3.IsValid, Is.EqualTo(true));
                Expect(v3.IsLockedOut, Is.EqualTo(true));
                Expect(v3.IsOutdated, Is.EqualTo(false));
                Expect(v3.IsFresh, Is.EqualTo(true));
            }
        }
    }
}
