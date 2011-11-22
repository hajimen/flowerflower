using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using FFCommon;
using Microsoft.Win32;

namespace FFScheduler
{
    public partial class TheService : ServiceBase
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private static readonly string RegistryNameLastUpdated = @"Last Updated";
        private Control syncObj;
        private SynchronizationContext workerContext;
        private Thread workerThread;
        private DateTime lastTimerElasped;

        public TheService()
        {
            InitializeComponent();
            Settings.Init();
        }

        protected override void OnStart(string[] args)
        {
            logger.Info("flowerflower scheduler start");
            workerThread = new Thread(new ThreadStart(OnStartWorkerThread));
            workerThread.Start();
        }

        protected override void OnStop()
        {
            timer.Enabled = false;
            Application.Exit();
            if (!workerThread.Join(2000))
            {
                workerThread.Abort();
            }
            logger.Info("flowerflower scheduler stop");
        }

        public void OnStartWorkerThread()
        {
            lock (this)
            {
                syncObj = new Control();
                timer.Enabled = true;
                workerContext = SynchronizationContext.Current;
            }
            try
            {
                Application.Run();
            }
            catch (Exception e)
            {
                logger.Info("Application.Run() throwed exception", e);
            }
        }

        public void OnTimerElapsed(object state)
        {
            try
            {
                OnTimerElapsedImpl();
            }
            catch (Exception e)
            {
                logger.Error("更新に失敗しました。", e);
            }
        }

        public void OnTimerElapsedImpl()
        {
            DateTime startDT = DateTime.Now;
            if (startDT.Minute == lastTimerElasped.Minute)
            {
                lastTimerElasped = startDT;
                return;
            }
            lastTimerElasped = startDT;

            RegistryKey rk = Registry.LocalMachine.OpenSubKey(Constant.RegistryKeyName);
            string lu = (string)rk.GetValue(RegistryNameLastUpdated);
            rk.Close();

            if (lu == null)
            {
                WriteLastUpdated(startDT);
                return;
            }

            DateTime lastDT = DateTime.Parse(lu);
            TimeSpan ts = startDT - lastDT;
            if (ts < new TimeSpan(0, 0, 58))
            {
                return;
            }

            Updater u = new Updater();
            u.Update(startDT, lastDT);

            WriteLastUpdated(startDT);
        }

        private void WriteLastUpdated(DateTime dt)
        {
            RegistryKey rk = Registry.LocalMachine.OpenSubKey(Constant.RegistryKeyName, true);
            rk.SetValue(RegistryNameLastUpdated, dt.ToString());
            rk.Close();
        }

        private void timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            workerContext.Post(OnTimerElapsed, null);
        }
    }
}
