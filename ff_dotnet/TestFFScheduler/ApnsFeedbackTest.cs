using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using System.Transactions;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using FFScheduler;

namespace TestFFScheduler
{
    [TestFixture]
    public class ApnsFeedbackTest : AssertionHelper
    {
        [SetUp]
        public void SetUp()
        {
        }

        [TearDown]
        public void TearDown()
        {
        }

        [Test]
        public void Test_ApnsFeedback()
        {
            Settings.TestSettings(null, typeof(FeedbackServiceStub));
            using (TransactionScope scope = new TransactionScope())
            {
                TitleTableAdapter tta = new TitleTableAdapter();
                tta.Insert("test title", "test push message", "test site root path", "test standby path");
                DataSet.TitleRow title = tta.GetDataByName("test title")[0];

                SubscriberTableAdapter sta = new SubscriberTableAdapter();
                sta.Insert(title.Id, "test authkey", "web", Constant.Ago);
                DataSet.SubscriberRow subscriber = sta.GetDataByTitleId(title.Id)[0];

                APNsTableAdapter ata = new APNsTableAdapter();
                ata.Insert(subscriber.Id, "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef", false, 0, false);

                ApnsFeedback fb = new ApnsFeedback(title);
                fb.Run();

                DataSet.APNsDataTable adt = ata.GetDataByTitleId(title.Id);
                Expect(adt[0].Failed, Is.EqualTo(true));
            }
        }
    }
}
