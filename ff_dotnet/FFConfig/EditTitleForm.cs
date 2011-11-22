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
        private static readonly string LvlKeyNotModified = "���̗���ҏW����Ɗ����̌��J�����㏑������܂��B";
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
                this.Text = "�V�����z�M�^�C�g��";
            }
            else
            {
                this.Text = "�z�M�^�C�g����ҏW";
                lvlPublikKeyTextBox.Text = LvlKeyNotModified;
            }
            titleNameTextBox.DataBindings.Add("Text", sourceTitle, "Name");
            apnsFilePathTextBox.DataBindings.Add("Text", sourceCredential, "ApnsPkcs12FilePath");
            apnsFilePasswordTextBox.DataBindings.Add("Text", sourceCredential, "ApnsPkcs12FilePassword");
            apnsIsSandboxCheckBox.DataBindings.Add("Checked", sourceCredential, "ApnsIsSandbox");
            lvlPackageNameTextBox.DataBindings.Add("Text", sourceCredential, "LvlPackageName");
            sitePathTextBox.DataBindings.Add("Text", sourceTitle, "SiteRootPath");
            standByPathTextBox.DataBindings.Add("Text", sourceTitle, "StandByPath");
            defaultPushMessageTextBox.DataBindings.Add("Text", sourceTitle, "PushMessage");
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
                MessageBox.Show("�z�M�^�C�g���̖��O����ł��B");
                return;
            }
            if (isNewTitle && new TitleTableAdapter().GetDataByName(titleNameTextBox.Text).Count > 0)
            {
                MessageBox.Show("�������O�̔z�M�^�C�g�������łɑ��݂��܂��B");
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
                    MessageBox.Show("Android LVL�̌��J�����s���Ȍ`���ł��B");
                    return;
                }
                if (lvlPublicKey.Length == 0)
                {
                    MessageBox.Show("Android LVL�̌��J�����Ԉ���Ă��܂��B");
                    return;
                }
                sourceCredential.LvlRsaKeyValue = lvlPublicKey;
            }

            if (lvlPackageNameTextBox.Text.Length == 0)
            {
                MessageBox.Show("Android�Ŕz�M�w�ǃA�v���̃p�b�P�[�W������ł��B");
                return;
            }

            if (!File.Exists(apnsFilePathTextBox.Text))
            {
                MessageBox.Show("APNs�̏ؖ����t�@�C�����w�肳��Ă��܂���B");
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
                MessageBox.Show("APNs�̏ؖ����t�@�C���܂��̓p�X���[�h���Ԉ���Ă��܂��B");
                return;
            }

            if (!Directory.Exists(sitePathTextBox.Text))
            {
                MessageBox.Show("�z�M�T�C�g�̕����p�X���w�肳��Ă��܂���B");
                return;
            }

            if (!Directory.Exists(standByPathTextBox.Text))
            {
                MessageBox.Show("�X�V���t�H���_�̃p�X���w�肳��Ă��܂���B");
                return;
            }

            if (defaultPushMessageTextBox.Text.Length == 0)
            {
                if (MessageBox.Show("�f�t�H���g�̔z�M�ʒm���b�Z�[�W����ł��B��낵���ł����H", "�m�F", MessageBoxButtons.OKCancel) == DialogResult.Cancel)
                {
                    return;
                }
            }

            DialogResult = DialogResult.OK;
        }
    }
}