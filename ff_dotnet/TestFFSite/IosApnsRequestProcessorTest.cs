using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;
using System.IO;
using NUnit.Framework;
using FFSite;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using FFSite.Office.IosApns;
using TestFFCommon;
using FFCommon.Apns;

namespace TestFFSite
{
    [TestFixture]
    public class IosApnsRequestProcessorTest : AssertionHelper
    {
        [SetUp]
        public void SetUp()
        {
            Settings.TestSettings(typeof(NotificationServiceStub), null);
        }

        [TearDown]
        public void TearDown()
        {
        }

        private DataSet.TitleRow PrepareBasic()
        {
            TitleTableAdapter tta = new TitleTableAdapter();
            tta.Insert("test title", "test push message", "test site root path", "test standby path");
            DataSet.TitleRow title = tta.GetDataByName("test title")[0];

            CredentialTableAdapter cta = new CredentialTableAdapter();
            DataSet.CredentialDataTable cdt = new DataSet.CredentialDataTable();
            cdt.AddCredentialRow(title, Credential.ApnsPkcs12FilePathKind, "test pkcs12filepath");
            cta.Update(cdt);
            cdt.AddCredentialRow(title, Credential.ApnsPkcs12FilePasswordKind, "test pkcs12filepassword");
            cta.Update(cdt);

            SiteConstant.TestSettings(title);

            return title;
        }

        private DataSet.SubscriberRow PrepareExist(DataSet.TitleRow title)
        {
            SubscriberTableAdapter sta = new SubscriberTableAdapter();
            DataSet.SubscriberDataTable sdt = new DataSet.SubscriberDataTable();
            sdt.AddSubscriberRow(title, "deadbeef", AuthScheme.iOS_APNs.ToString(), Constant.Ago);
            sta.Update(sdt);
            DataSet.SubscriberRow subscriber = sdt[0];

            APNsTableAdapter ata = new APNsTableAdapter();
            DataSet.APNsDataTable adt = new DataSet.APNsDataTable();
            adt.AddAPNsRow(subscriber, "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef", false, 0, false);
            ata.Update(adt);

            TokenTableAdapter tta = new TokenTableAdapter();
            DataSet.TokenDataTable tdt = new DataSet.TokenDataTable();
            tdt.AddTokenRow(subscriber, DateTime.Now - new TimeSpan(48, 0, 0), "deadbeef", true);
            tta.Update(tdt);

            return subscriber;
        }

        [Test]
        public void Test_Process_NewSubscriber()
        {
            using (TransactionScope scope = new TransactionScope())
            {
                DataSet.TitleRow title = PrepareBasic();

                RequestProcessor rp = new RequestProcessor();
                rp.Process("deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef");

                APNsTableAdapter ata = new APNsTableAdapter();
                DataSet.APNsDataTable adt = ata.GetDataByTitleId(title.Id);
                Expect(adt.Count, Is.EqualTo(1));
                Expect(adt[0].DeviceToken, Is.EqualTo("deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"));

                SubscriberTableAdapter sta = new SubscriberTableAdapter();
                DataSet.SubscriberDataTable sdt = sta.GetDataByTitleId(title.Id);
                Expect(sdt.Count, Is.EqualTo(1));
                DataSet.SubscriberRow subscriber = sdt[0];
                Expect(subscriber.AuthScheme, Is.EqualTo(AuthScheme.iOS_APNs.ToString()));

                TokenTableAdapter tta = new TokenTableAdapter();
                DataSet.TokenDataTable tdt = tta.GetDataBySubscriberId(subscriber.Id);
                Expect(tdt.Count, Is.EqualTo(1));
            }
        }

        [Test]
        public void Test_Process_BadDeviceToken()
        {
            using (TransactionScope scope = new TransactionScope())
            {
                DataSet.TitleRow title = PrepareBasic();

                RequestProcessor rp = new RequestProcessor();
                try
                {
                    rp.Process("malformeddevicetokenmalformeddevicetokenmalformeddevicetokenmalf");
                    Expect(false);
                }
                catch (BadDeviceTokenException)
                {
                    // OK
                }

                APNsTableAdapter ata = new APNsTableAdapter();
                DataSet.APNsDataTable adt = ata.GetDataByTitleId(title.Id);
                Expect(adt.Count, Is.EqualTo(0));

                SubscriberTableAdapter sta = new SubscriberTableAdapter();
                DataSet.SubscriberDataTable sdt = sta.GetDataByTitleId(title.Id);
                Expect(sdt.Count, Is.EqualTo(0));
            }
        }

        [Test]
        public void Test_Process_ExistSubscriber()
        {
            using (TransactionScope scope = new TransactionScope())
            {
                DataSet.TitleRow title = PrepareBasic();
                DataSet.SubscriberRow subscriber = PrepareExist(title);

                RequestProcessor rp = new RequestProcessor();
                rp.Process("deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef");

                APNsTableAdapter ata = new APNsTableAdapter();
                DataSet.APNsDataTable adt = ata.GetDataByTitleId(title.Id);
                Expect(adt.Count, Is.EqualTo(1));
                Expect(adt[0].DeviceToken, Is.EqualTo("deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"));

                TokenTableAdapter tta = new TokenTableAdapter();
                DataSet.TokenDataTable tdt = tta.GetDataBySubscriberId(subscriber.Id);
                Expect(tdt.Count, Is.EqualTo(2));
            }
        }

        [Test]
        public void Test_Process_ExistSubscriber_ApnsFailed()
        {
            using (TransactionScope scope = new TransactionScope())
            {
                DataSet.TitleRow title = PrepareBasic();
                DataSet.SubscriberRow subscriber = PrepareExist(title);

                APNsTableAdapter ata = new APNsTableAdapter();
                DataSet.APNsDataTable adt = ata.GetDataByTitleId(title.Id);
                adt[0].Failed = true;
                ata.Update(adt);

                RequestProcessor rp = new RequestProcessor();
                rp.Process("deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef");

                adt = ata.GetDataByTitleId(title.Id);
                Expect(adt[0].Failed, Is.EqualTo(false));
            }
        }
}
}
