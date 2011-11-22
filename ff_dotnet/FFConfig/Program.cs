using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace FFConfig
{
    static class Program
    {
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            FFCommon.Settings.Init();
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new TitleListForm());
        }
    }
}