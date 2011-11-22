using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using System.IO;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using TestFFCommon;
using System.Transactions;

namespace FFScheduler
{
    [TestFixture]
    class TestUpdater : AssertionHelper
    {
        string basePath = Path.GetFullPath(@"..\..\unittest");

        [SetUp]
        public void SetUp()
        {
            Directory.CreateDirectory(basePath + @"\copyDirectory_dist");
        }
        
        [TearDown]
        public void TearDown()
        {
            Directory.Delete(basePath + @"\copyDirectory_dist", true);
        }
        
        [Test]
        public void Test_CopyDirectory()
        {
            Updater u = new Updater();
            u.CopyDirectory(basePath + @"\copyDirectory_orig\20111102_1530", basePath + @"\copyDirectory_dist");
            Expect(u.PushMessage, Is.EqualTo("push message 1"));
        }
        
        [Test]
        public void Test_Update()
        {
            Settings.TestSettings(typeof(NotificationServiceStub), typeof(FeedbackServiceStub));
            using (TransactionScope scope = new TransactionScope())
            {
                TitleTableAdapter tta = new TitleTableAdapter();
                tta.Insert("test title", "test push message", basePath + @"\copyDirectory_dist", basePath + @"\copyDirectory_orig");
                DataSet.TitleRow title = tta.GetDataByName("test title")[0];

                SubscriberTableAdapter sta = new SubscriberTableAdapter();
                sta.Insert(title.Id, "test authkey", "web", Constant.Ago);
                DataSet.SubscriberRow subscriber = sta.GetDataByTitleId(title.Id)[0];

                APNsTableAdapter ata = new APNsTableAdapter();
                ata.Insert(subscriber.Id, "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef", false, 0, false);

                Updater u = new Updater();
                u.Update(new DateTime(2011, 11, 2, 15, 30, 0), new DateTime(2011, 11, 2, 15, 29, 0));

                DataSet.APNsDataTable adt = ata.GetDataByTitleId(title.Id);
                Expect(adt[0].UnreadRelease, Is.EqualTo(1));
            }
        }
    }
}
