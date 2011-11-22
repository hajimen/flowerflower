using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using FFCommon;
using FFCommon.DataSetTableAdapters;

namespace FFConfig
{
    public partial class TitleListForm : Form
    {
        public TitleListForm()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.titleTableAdapter.Fill(this.dataSet.Title);

        }

        private void CloseButton_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void NewTitleButton_Click(object sender, EventArgs e)
        {
            DataSet.TitleDataTable dt = new DataSet.TitleDataTable();
            DataSet.TitleRow title = dt.AddTitleRow("", "", "", "");
            Credential c = new Credential();
            using (EditTitleForm f = new EditTitleForm(true, ref title, ref c))
            {
                if (f.ShowDialog() == DialogResult.OK)
                {
                    titleTableAdapter.Update(dt);
                    CredentialTableAdapter cta = new CredentialTableAdapter();
                    DataSet.CredentialDataTable cdt = new DataSet.CredentialDataTable();
                    cdt.AddCredentialRow(title, Credential.ApnsPkcs12FilePathKind, c.ApnsPkcs12FilePath);
                    cta.Update(cdt);
                    cdt.AddCredentialRow(title, Credential.ApnsPkcs12FilePasswordKind, c.ApnsPkcs12FilePassword);
                    cta.Update(cdt);
                    cdt.AddCredentialRow(title, Credential.ApnsIsSandboxKind, c.ApnsIsSandbox.ToString());
                    cta.Update(cdt);
                    cdt.AddCredentialRow(title, Credential.LvlRsaKeyValueKind, c.LvlRsaKeyValue);
                    cta.Update(cdt);
                    cdt.AddCredentialRow(title, Credential.LvlPackageNameKind, c.LvlPackageName);
                    cta.Update(cdt);

                    this.titleTableAdapter.Fill(this.dataSet.Title);
                    MessageBox.Show("新しい配信タイトルを追加しました");
                }
            }
        }

        private void deleteTitleButton_Click(object sender, EventArgs e)
        {
            if (titleDataGridView.SelectedRows.Count == 0)
            {
                return;
            }
            string titleName = titleDataGridView.SelectedRows[0].Cells[1].Value.ToString();
            if (MessageBox.Show(string.Format(@"本当に {0} を削除しますか？", titleName),
                "確認", MessageBoxButtons.OKCancel) != DialogResult.OK)
            {
                return;
            }
            long titleId = long.Parse(titleDataGridView.SelectedRows[0].Cells[0].Value.ToString());
            titleTableAdapter.DeleteCascade(titleId);
            this.titleTableAdapter.Fill(this.dataSet.Title);
        }

        private void editTitleButton_Click(object sender, EventArgs e)
        {
            if (titleDataGridView.SelectedRows.Count == 0)
            {
                return;
            }
            long titleId = long.Parse(titleDataGridView.SelectedRows[0].Cells[0].Value.ToString());
            DataSet.TitleRow title = titleTableAdapter.GetDataById(titleId)[0];
            Credential c = new Credential(title);
            using (EditTitleForm f = new EditTitleForm(false, ref title, ref c))
            {
                if (f.ShowDialog() == DialogResult.OK)
                {
                    CredentialTableAdapter cta = new CredentialTableAdapter();
                    DataSet.CredentialDataTable cdt = cta.GetDataByTitleId(title.Id);
                    
                    foreach (DataSet.CredentialRow cr in cdt)
                    {
                        if (cr.Kind == Credential.ApnsPkcs12FilePathKind)
                        {
                            cr.Body = c.ApnsPkcs12FilePath;
                        }
                        if (cr.Kind == Credential.ApnsPkcs12FilePasswordKind)
                        {
                            cr.Body = c.ApnsPkcs12FilePassword;
                        }
                        if (cr.Kind == Credential.ApnsIsSandboxKind)
                        {
                            cr.Body = c.ApnsIsSandbox.ToString();
                        }
                        if (cr.Kind == Credential.LvlRsaKeyValueKind)
                        {
                            cr.Body = c.LvlRsaKeyValue;
                        }
                        if (cr.Kind == Credential.LvlPackageNameKind)
                        {
                            cr.Body = c.LvlPackageName;
                        }
                    }
                    cta.Update(cdt);
                    this.titleTableAdapter.Update(title);
                    this.titleTableAdapter.Fill(this.dataSet.Title);
                }
            }
        }
    }
}