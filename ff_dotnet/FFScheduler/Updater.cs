using System;
using System.Collections.Generic;
using System.Text;
using FFCommon;
using FFCommon.DataSetTableAdapters;
using System.IO;
using Newtonsoft.Json;
using System.Web.Script.Serialization;

namespace FFScheduler
{
    public class Updater
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private DateTime startDT, lastDT;
        private string pushMessage = null;

        public string PushMessage
        {
            get { return pushMessage; }
        }

        public Updater()
        {
        }

        public void Update(DateTime startDT, DateTime lastDT)
        {
            this.startDT = startDT;
            this.lastDT = lastDT;

            DataSet ds = new DataSet();
            TitleTableAdapter ta = new TitleTableAdapter();
            ta.Fill(ds.Title);

            foreach(DataSet.TitleRow t in ds.Title)
            {
                try
                {
                    UpdateTitle(t);
                }
                catch (Exception e)
                {
                    logger.Error(String.Format("Title.Id='{0}' Title.Name='{1}'の更新に失敗しました。", t.Id, t.Name), e);
                }
            }
        }

        private void UpdateTitle(DataSet.TitleRow title)
        {
            if (!Directory.Exists(title.StandByPath))
            {
                throw new IllegalSetupStateException(String.Format("Title.StandByPath='{0}'がディレクトリを示していません。", title.StandByPath));
            }
            if (!Directory.Exists(title.SiteRootPath))
            {
                throw new IllegalSetupStateException(String.Format("Title.SiteRootPath='{0}'がディレクトリを示していません。", title.SiteRootPath));
            }

            List<DateTime> dtList = new List<DateTime>();

            foreach (string d in Directory.GetDirectories(title.StandByPath))
            {
                string n = Path.GetFileName(d);
                try
                {
                    DateTime dt = DateTime.ParseExact(n, "yyyyMMdd_HHmm", null);
                    dtList.Add(dt);
                    if (startDT >= dt && dt > lastDT)
                    {
                        CopyDirectory(d, title.SiteRootPath);
                        if (pushMessage != null)
                        {
                            ApnsPusher pusher = ApnsPusher.GetInstance(title);
                            pusher.PushReleaseNotification(pushMessage);
                        }
                    }
                }
                catch (FormatException)
                {
                }
            }

            dtList.Sort();
            DateTime nextRelease = DateTime.MinValue;
            for (int i = 1; i < dtList.Count; i++)
            {
                if (dtList[i] > startDT && startDT >= dtList[i - 1])
                {
                    nextRelease = dtList[i];
                    break;
                }
            }

            using (StreamWriter sw = new StreamWriter(Path.Combine(title.SiteRootPath, Constant.ToNextReleaseFilename), false))
            {
                if (nextRelease == DateTime.MinValue)
                {
                    sw.Write("-1");
                }
                else
                {
                    TimeSpan toNextRelease = nextRelease - startDT + Constant.UpdateMarginSpan;
                    sw.Write(Math.Floor(toNextRelease.TotalMilliseconds).ToString());
                }
            }

            if (startDT.Day != lastDT.Day)
            {
                ApnsFeedback feedback = new ApnsFeedback(title);
                feedback.Run();
            }

            using (StreamWriter sw = new StreamWriter(Path.Combine(title.SiteRootPath, Constant.WatchDogFilename), false))
            {
                sw.Write(Constant.Random.Next().ToString());
            }
        }

        public void CopyDirectory(string origPath, string distPath)
        {
            foreach (string fn in Directory.GetFiles(origPath))
            {
                if (Path.GetFileName(fn) == Constant.CatalogueFilename)
                {
                    using (StreamReader sr = new StreamReader(fn, Encoding.GetEncoding("UTF-8")))
                    {
                        JavaScriptSerializer js = new JavaScriptSerializer();
                        IDictionary<string, object> catalogue = (IDictionary<string, object>)js.DeserializeObject(sr.ReadToEnd());
                        if (catalogue.ContainsKey(Constant.CataloguePushMessageKeyName))
                        {
                            pushMessage = js.ConvertToType<string>(catalogue[Constant.CataloguePushMessageKeyName]);
                        }
                    }
                }
                File.Copy(fn, distPath + @"\" + Path.GetFileName(fn), true);
            }
            foreach (string dn in Directory.GetDirectories(origPath))
            {
                string newDistPath = distPath + @"\" + Path.GetFileName(dn);
                if (!Directory.Exists(newDistPath))
                {
                    Directory.CreateDirectory(newDistPath);
                }
                CopyDirectory(dn, newDistPath);
            }

            return;
        }
    }
}
