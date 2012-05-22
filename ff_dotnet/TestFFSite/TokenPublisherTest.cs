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
    public class TokenPublisherTest : AssertionHelper
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
                sta.Insert(title.Id, "test authkey", AuthScheme.Web.ToString(), Constant.Ago);
                sta.Insert(title.Id, "test authkey 2", AuthScheme.Web.ToString(), new DateTime(2011, 10, 13));
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
                kta.Insert(s1.Id, new DateTime(2011, 10, 12, 0, 0, 0), "deadbeef", true);
                kta.Insert(s2.Id, new DateTime(2011, 10, 12, 4, 59, 50), "deadbeef2", false);
                DataSet.TokenRow k1, k2;
                k1 = kta.GetDataByBody("deadbeef")[0];
                k2 = kta.GetDataByBody("deadbeef2")[0];

                Expect(SiteConstant.IsConfigurationOK, Is.EqualTo(true));

                DateTime now = new DateTime(2011, 10, 12, 5, 0, 0);

                TokenPublisher p1 = new TokenPublisher(s1, now);
                DataSet.TokenRow pk1 = p1.Publish();
                Expect(pk1.Id, Is.Not.EqualTo(k1.Id));

                TokenPublisher p2 = new TokenPublisher(s2, now);
                DataSet.TokenRow pk2 = p2.Publish();
                Expect(pk2.Id, Is.EqualTo(k2.Id));

                kta.Insert(s2.Id, new DateTime(2011, 10, 12, 4, 59, 10), "deadbeef3", true);
                kta.Insert(s2.Id, new DateTime(2011, 10, 12, 4, 59, 20), "deadbeef4", true);

                TokenPublisher p2_2 = new TokenPublisher(s2, now);
                try
                {
                    p2_2.Publish();
                    Expect(false);
                }
                catch (DoubtfulAuthBehaviorException)
                {
                    // OK
                }
                Expect(kta.GetDataBySubscriberId(s2.Id).Count, Is.EqualTo(3));
            }
        }
    }
}
