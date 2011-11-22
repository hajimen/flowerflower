using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using System.Transactions;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using System.IO;

namespace TestFFCommon
{
    [TestFixture]
    public class ApnsPusherTest : AssertionHelper
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        [SetUp]
        public void SetUp()
        {
        }

        [TearDown]
        public void TearDown()
        {
        }

        [Test]
        public void TestNotification()
        {
            logger.Info("test");
//            Settings.TestSettings(typeof(NotificationServiceStub), null);
            using (TransactionScope scope = new TransactionScope())
            {
                TitleTableAdapter tta = new TitleTableAdapter();
                DataSet.TitleDataTable tdt = new DataSet.TitleDataTable();
                tdt.AddTitleRow("test title", "test push message", "test site root path", "test standby path");
                tta.Update(tdt);
                DataSet.TitleRow title = tdt[0];

                CredentialTableAdapter cta = new CredentialTableAdapter();
                DataSet.CredentialDataTable cdt = new DataSet.CredentialDataTable();
                cdt.AddCredentialRow(title, Credential.ApnsPkcs12FilePathKind, SecureConstant.P12File);
                cta.Update(cdt);
                cdt.AddCredentialRow(title, Credential.ApnsPkcs12FilePasswordKind, SecureConstant.P12FilePassword);
                cta.Update(cdt);
                cdt.AddCredentialRow(title, Credential.LvlRsaKeyValueKind, "test lvlrsakeyvalue");
                cta.Update(cdt);

                SubscriberTableAdapter sta = new SubscriberTableAdapter();
                DataSet.SubscriberDataTable sdt = new DataSet.SubscriberDataTable();
                sdt.AddSubscriberRow(title, "test authkey", "web", Constant.Ago);
                sta.Update(sdt);
                DataSet.SubscriberRow subscriber = sdt[0];

                APNsTableAdapter ata = new APNsTableAdapter();
                ata.Insert(subscriber.Id, "B9C83DAE377DDEEECB7C9EA662F7BFBC5D3FA95A5AD5E3CD4B0DD843E0D9EBED", false, 0, false);

                ApnsPusher p = ApnsPusher.GetInstance(title);
                p.PushReleaseNotification("test push message 2");
                System.Threading.Thread.Sleep(10000); // すぐに終了すると通信が間に合わない（実際に送信する場合）

                DataSet.APNsDataTable adt = ata.GetDataByTitleId(title.Id);
                Expect(adt[0].UnreadRelease, Is.EqualTo(1));
            }
        }
    }
}
