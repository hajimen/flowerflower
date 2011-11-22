using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;
using System.IO;
using NUnit.Framework;
using FFSite;
using FFSite.Office.AndroidLvl;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace TestFFSite
{
    [TestFixture]
    public class LvlVerifierTest : AssertionHelper
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
        public void Test_IsOK()
        {
            using (TransactionScope scope = new TransactionScope())
            {
                TitleTableAdapter tta = new TitleTableAdapter();
                tta.Insert("test title", "test push message", "test dir", "test dir");
                DataSet.TitleRow title = tta.GetDataByName("test title")[0];

                CredentialTableAdapter cta = new CredentialTableAdapter();
                DataSet.CredentialDataTable cdt = new DataSet.CredentialDataTable();
                cdt.AddCredentialRow(title, Credential.LvlPackageNameKind, "org.kaoriha.flowerflower");
                cta.Update(cdt);
                cdt.AddCredentialRow(title, Credential.LvlRsaKeyValueKind, "<RSAKeyValue><Modulus>lzqteVeU/xQAa5fNe6v/s+HZ2F6IZ953LG3tmKjW7JGzK9BJGaE+s5PZgd0ZFG+q9DWa80PQB2mxRaSoPZwe8ystMErjOoeFdXE5RVTXxBIu4YaqRAKTNcj5ki5qr2emalsBFU5w9CJHRCGta+0ByIR5KyCPvK6wgmDwLdG1MHPxLFgDXHcQmIDAwkhovD9thin9RvyVG4C2zeEwcynYHoEVBPtdeBGX4VxX6KkIGE7hxV1/BQt32j0xrX1luq7YBw9XOAlXehj9oMxg0ZGcYT9dD7CAYDOJvoOoKZL4dmyvBon249dUE2af+QrxfT6dGglRVIVlxaPBC6NixGOc+Q==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>");
                cta.Update(cdt);

                DateTime now = new DateTime(2011, 10, 14);
                LVLTableAdapter lta = new LVLTableAdapter();
                DataSet.LVLDataTable ldt = new DataSet.LVLDataTable();
                ldt.AddLVLRow(105002991, now);
                lta.Update(ldt);
                DataSet.LVLRow lvl = ldt[0];

                Verifier v = new Verifier(lvl.Id, "3|105002991|org.kaoriha.flowerflower|1|ANlOHQM/Rs23FkGZEoX2p4DicHHRN68KEw==|1316406950698",
                    "IuI1h8lefJGUfkXxleI7hERAiDBp0Rx8ItdKbUd/n9ObLA0odCfN3siqxd82I3MpgEJ6YL+zcK6dwHcjhioGN4nSI0rORIpTOrQt2zbsKWK7DAvlefeY3BDPTtm/73Z2gNVt1cv7RIaee/eVARMA8o0J5mxijoAkA6wybEW4fxpHZKG1sFH2UyNz8eZ1hEBg8YLi4yGKI2HNrTSgHgmTUXoT30qbjXf91jvqL2rSdtbHTHibDmKmu7kp+gk0H8eNRijmNwAQqoEGMPhqyv18tpth7UWNb0GnG0f+RYJDVyLhT84Iy+g3wN+JPjXGAADVVotOTTMuec113FlF1wvsIA==", now);
                Expect(v.IsOK(), Is.EqualTo(true));

                Verifier v2 = new Verifier(lvl.Id, "1|105002991|org.kaoriha.flowerflower|1|ANlOHQM/Rs23FkGZEoX2p4DicHHRN68KEw==|1316406950698",
                    "IuI1h8lefJGUfkXxleI7hERAiDBp0Rx8ItdKbUd/n9ObLA0odCfN3siqxd82I3MpgEJ6YL+zcK6dwHcjhioGN4nSI0rORIpTOrQt2zbsKWK7DAvlefeY3BDPTtm/73Z2gNVt1cv7RIaee/eVARMA8o0J5mxijoAkA6wybEW4fxpHZKG1sFH2UyNz8eZ1hEBg8YLi4yGKI2HNrTSgHgmTUXoT30qbjXf91jvqL2rSdtbHTHibDmKmu7kp+gk0H8eNRijmNwAQqoEGMPhqyv18tpth7UWNb0GnG0f+RYJDVyLhT84Iy+g3wN+JPjXGAADVVotOTTMuec113FlF1wvsIA==", now);
                Expect(v2.IsOK(), Is.EqualTo(false));

                Verifier v3 = new Verifier(lvl.Id + 1, "3|105002991|org.kaoriha.flowerflower|1|ANlOHQM/Rs23FkGZEoX2p4DicHHRN68KEw==|1316406950698",
                    "IuI1h8lefJGUfkXxleI7hERAiDBp0Rx8ItdKbUd/n9ObLA0odCfN3siqxd82I3MpgEJ6YL+zcK6dwHcjhioGN4nSI0rORIpTOrQt2zbsKWK7DAvlefeY3BDPTtm/73Z2gNVt1cv7RIaee/eVARMA8o0J5mxijoAkA6wybEW4fxpHZKG1sFH2UyNz8eZ1hEBg8YLi4yGKI2HNrTSgHgmTUXoT30qbjXf91jvqL2rSdtbHTHibDmKmu7kp+gk0H8eNRijmNwAQqoEGMPhqyv18tpth7UWNb0GnG0f+RYJDVyLhT84Iy+g3wN+JPjXGAADVVotOTTMuec113FlF1wvsIA==", now);
                Expect(v3.IsOK(), Is.EqualTo(false));
            }
        }
    }
}
