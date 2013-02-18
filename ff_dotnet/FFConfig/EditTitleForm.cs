using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace FFConfig
{
    public partial class EditTitleForm : Form
    {
        private static readonly string LvlKeyNotModified = "この欄を編集すると既存の公開鍵が上書きされます。";
        private DataSet.TitleRow sourceTitle;
        private Credential sourceCredential;
        private bool isNewTitle;

        public EditTitleForm(bool isNewTitle, ref DataSet.TitleRow sourceTitle, ref Credential sourceCredential)
        {
            this.sourceTitle = sourceTitle;
            this.sourceCredential = sourceCredential;
            this.isNewTitle = isNewTitle;

            InitializeComponent();

            if (isNewTitle)
            {
                this.Text = "新しい配信タイトル";
            }
            else
            {
                this.Text = "配信タイトルを編集";
                lvlPublikKeyTextBox.Text = LvlKeyNotModified;
            }
            titleNameTextBox.DataBindings.Add("Text", sourceTitle, "Name");
            apnsFilePathTextBox.DataBindings.Add("Text", sourceCredential, "ApnsPkcs12FilePath");
            apnsFilePasswordTextBox.DataBindings.Add("Text", sourceCredential, "ApnsPkcs12FilePassword");
            apnsIsSandboxCheckBox.DataBindings.Add("Checked", sourceCredential, "ApnsIsSandbox");
            lvlPackageNameTextBox.DataBindings.Add("Text", sourceCredential, "LvlPackageName");
            sitePathTextBox.DataBindings.Add("Text", sourceTitle, "SiteRootPath");
            standByPathTextBox.DataBindings.Add("Text", sourceTitle, "StandByPath");
        }

        private void apnsFileBrowseButton_Click(object sender, EventArgs e)
        {
            if (apnsFileDialog.ShowDialog() == DialogResult.OK)
            {
                apnsFilePathTextBox.Text = apnsFileDialog.FileName;
                sourceCredential.ApnsPkcs12FilePath = apnsFileDialog.FileName;
            }
        }

        private void sitePathBrowseButton_Click(object sender, EventArgs e)
        {
            if (sitePathBrowserDialog.ShowDialog() == DialogResult.OK)
            {
                sitePathTextBox.Text = sitePathBrowserDialog.SelectedPath;
                sourceTitle.SiteRootPath = sitePathBrowserDialog.SelectedPath;
            }
        }

        private void standByPathButton_Click(object sender, EventArgs e)
        {
            if (standByPathBrowserDialog.ShowDialog() == DialogResult.OK)
            {
                standByPathTextBox.Text = standByPathBrowserDialog.SelectedPath;
                sourceTitle.StandByPath = standByPathBrowserDialog.SelectedPath;
            }
        }

        private void okButton_Click(object sender, EventArgs e)
        {
            if (titleNameTextBox.Text.Length == 0)
            {
                MessageBox.Show("配信タイトルの名前が空です。");
                return;
            }
            if (isNewTitle && new TitleTableAdapter().GetDataByName(titleNameTextBox.Text).Count > 0)
            {
                MessageBox.Show("同じ名前の配信タイトルがすでに存在します。");
                return;
            }

            if (lvlPublikKeyTextBox.Text != LvlKeyNotModified)
            {
                string lvlPublicKey = "";
                try
                {
                    pempublic.Entry(lvlPublikKeyTextBox.Text, ref lvlPublicKey);
                }
                catch (Exception)
                {
                    MessageBox.Show("Android LVLの公開鍵が不正な形式です。");
                    return;
                }
                if (lvlPublicKey.Length == 0)
                {
                    MessageBox.Show("Android LVLの公開鍵が間違っています。");
                    return;
                }
                sourceCredential.LvlRsaKeyValue = lvlPublicKey;
            }

            if (lvlPackageNameTextBox.Text.Length == 0)
            {
                MessageBox.Show("Android版配信購読アプリのパッケージ名が空です。");
                return;
            }

            if (!File.Exists(apnsFilePathTextBox.Text))
            {
                MessageBox.Show("APNsの証明書ファイルが指定されていません。");
                return;
            }
            try
            {
                X509Certificate2 certificate;
                if (string.IsNullOrEmpty(apnsFilePasswordTextBox.Text))
                    certificate = new X509Certificate2(File.ReadAllBytes(apnsFilePathTextBox.Text));
                else
                    certificate = new X509Certificate2(File.ReadAllBytes(apnsFilePathTextBox.Text), apnsFilePasswordTextBox.Text);
                PublicKey pk = certificate.PublicKey;
            }
            catch (Exception)
            {
                MessageBox.Show("APNsの証明書ファイルまたはパスワードが間違っています。");
                return;
            }

            if (!Directory.Exists(sitePathTextBox.Text))
            {
                MessageBox.Show("配信サイトの物理パスが指定されていません。");
                return;
            }

            if (!Directory.Exists(standByPathTextBox.Text))
            {
                MessageBox.Show("更新元フォルダのパスが指定されていません。");
                return;
            }

            DialogResult = DialogResult.OK;
        }
    }
}