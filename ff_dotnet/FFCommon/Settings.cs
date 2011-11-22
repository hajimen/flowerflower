using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Win32;
using System.Runtime.InteropServices;
using System.Configuration;
using FFCommon.Apns;

namespace FFCommon
{
    public class Settings
    {
        private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static readonly string RegistryNameConnectionString = @"Connection String";
        private static Type NotificationServiceType = typeof(NotificationServiceImpl);
        private static Type FeedbackServiceType = typeof(FeedbackServiceImpl);

        private Settings()
        {
        }

        static Settings()
        {
            RegistryKey rk = Registry.LocalMachine.OpenSubKey(Constant.RegistryKeyName);
            PlatformCheck pc = new PlatformCheck();
            if (pc.IsWow64())
            {
                logger.Info("Running Environment: wow64");
            }
            else if (pc.Is64BitOS())
            {
                logger.Info("Running Environment: x64");
            }
            else
            {
                logger.Info("Running Environment: x86");
            }
            string cs = (string)rk.GetValue(RegistryNameConnectionString);
            rk.Close();
            if (cs == null)
            {
                throw new IllegalSetupStateException("レジストリにConnection Stringが見つかりません。");
            }
            Properties.Settings.Default.ff_dbConnectionString = cs;
        }

        public static void Init()
        {
        }

        public static void TestSettings(Type notificationServiceType, Type feedbackServiceType)
        {
            logger.Info("Settings.TestSettings enabled");
            NotificationServiceType = notificationServiceType;
            FeedbackServiceType = feedbackServiceType;
        }

        public static ANotificationService NewNotificationService(bool isSandbox, string p12file, string p12password)
        {
            object[] args = new object[3];
            args[0] = isSandbox;
            args[1] = p12file;
            args[2] = p12password;
            return (ANotificationService)Activator.CreateInstance(NotificationServiceType, args);
        }

        public static AFeedbackService NewFeedbackService(bool isSandbox, string p12file, string p12password)
        {
            object[] args = new object[3];
            args[0] = isSandbox;
            args[1] = p12file;
            args[2] = p12password;
            return (AFeedbackService)Activator.CreateInstance(FeedbackServiceType, args);
        }
    }

    class PlatformCheck
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr GetModuleHandle(string lpModuleName);

        [DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true)]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        [DllImport("kernel32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool IsWow64Process([In] IntPtr hProcess, [Out] out bool lpSystemInfo);

        //現在のプロセスがWOW32上で動作しているか調べる
        public bool IsWow64()
        {
            //IsWow64Processが使えるか調べる
            IntPtr wow64Proc = GetProcAddress(GetModuleHandle("Kernel32.dll"), "IsWow64Process");
            if (wow64Proc != IntPtr.Zero)
            {
                //IsWow64Processを呼び出す
                bool ret;
                if (IsWow64Process(System.Diagnostics.Process.GetCurrentProcess().Handle, out ret))
                {
                    return ret;
                }
            }

            return false;
        }

        //OSが64ビットか調べる
        public bool Is64BitOS()
        {
            if (IntPtr.Size == 4)
            {
                if (IsWow64())
                {
                    //OSは64ビットです
                    return true;
                }
                else
                {
                    //OSは32ビットです
                    return false;
                }
            }
            else if (IntPtr.Size == 8)
            {
                //OSは64ビットです
                return true;
            }

            return false;
        }
    }
}
