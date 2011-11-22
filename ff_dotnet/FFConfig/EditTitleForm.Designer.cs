namespace FFConfig
{
    partial class EditTitleForm
    {
        /// <summary>
        /// 必要なデザイナ変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージ リソースが破棄される場合 true、破棄されない場合は false です。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows フォーム デザイナで生成されたコード

        /// <summary>
        /// デザイナ サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディタで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            this.apnsFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.apnsFilePathTextBox = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.apnsFileBrowseButton = new System.Windows.Forms.Button();
            this.apnsFilePasswordTextBox = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.lvlPublikKeyTextBox = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.sitePathTextBox = new System.Windows.Forms.TextBox();
            this.sitePathBrowseButton = new System.Windows.Forms.Button();
            this.label5 = new System.Windows.Forms.Label();
            this.defaultPushMessageTextBox = new System.Windows.Forms.TextBox();
            this.cancelButton = new System.Windows.Forms.Button();
            this.okButton = new System.Windows.Forms.Button();
            this.sitePathBrowserDialog = new System.Windows.Forms.FolderBrowserDialog();
            this.label6 = new System.Windows.Forms.Label();
            this.standByPathTextBox = new System.Windows.Forms.TextBox();
            this.standByPathButton = new System.Windows.Forms.Button();
            this.standByPathBrowserDialog = new System.Windows.Forms.FolderBrowserDialog();
            this.label7 = new System.Windows.Forms.Label();
            this.titleNameTextBox = new System.Windows.Forms.TextBox();
            this.label8 = new System.Windows.Forms.Label();
            this.lvlPackageNameTextBox = new System.Windows.Forms.TextBox();
            this.apnsIsSandboxCheckBox = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // apnsFileDialog
            // 
            this.apnsFileDialog.DefaultExt = "p12";
            this.apnsFileDialog.Filter = "PKCS12 ファイル|*.p12";
            this.apnsFileDialog.ReadOnlyChecked = true;
            this.apnsFileDialog.Title = "APNsの証明書ファイル";
            // 
            // apnsFilePathTextBox
            // 
            this.apnsFilePathTextBox.Location = new System.Drawing.Point(161, 39);
            this.apnsFilePathTextBox.Name = "apnsFilePathTextBox";
            this.apnsFilePathTextBox.Size = new System.Drawing.Size(254, 19);
            this.apnsFilePathTextBox.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 42);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(142, 12);
            this.label1.TabIndex = 1;
            this.label1.Text = "APNsの証明書ファイル(.p12)";
            // 
            // apnsFileBrowseButton
            // 
            this.apnsFileBrowseButton.Location = new System.Drawing.Point(421, 37);
            this.apnsFileBrowseButton.Name = "apnsFileBrowseButton";
            this.apnsFileBrowseButton.Size = new System.Drawing.Size(57, 23);
            this.apnsFileBrowseButton.TabIndex = 2;
            this.apnsFileBrowseButton.Text = "開く";
            this.apnsFileBrowseButton.UseVisualStyleBackColor = true;
            this.apnsFileBrowseButton.Click += new System.EventHandler(this.apnsFileBrowseButton_Click);
            // 
            // apnsFilePasswordTextBox
            // 
            this.apnsFilePasswordTextBox.Location = new System.Drawing.Point(161, 65);
            this.apnsFilePasswordTextBox.Name = "apnsFilePasswordTextBox";
            this.apnsFilePasswordTextBox.PasswordChar = '*';
            this.apnsFilePasswordTextBox.Size = new System.Drawing.Size(254, 19);
            this.apnsFilePasswordTextBox.TabIndex = 3;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(103, 68);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(52, 12);
            this.label2.TabIndex = 4;
            this.label2.Text = "パスワード";
            // 
            // lvlPublikKeyTextBox
            // 
            this.lvlPublikKeyTextBox.Location = new System.Drawing.Point(15, 181);
            this.lvlPublikKeyTextBox.Multiline = true;
            this.lvlPublikKeyTextBox.Name = "lvlPublikKeyTextBox";
            this.lvlPublikKeyTextBox.Size = new System.Drawing.Size(463, 151);
            this.lvlPublikKeyTextBox.TabIndex = 6;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(13, 166);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(114, 12);
            this.label3.TabIndex = 6;
            this.label3.Text = "Android LVLの公開鍵";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(46, 347);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(109, 12);
            this.label4.TabIndex = 7;
            this.label4.Text = "配信サイトの物理パス";
            // 
            // sitePathTextBox
            // 
            this.sitePathTextBox.Location = new System.Drawing.Point(161, 344);
            this.sitePathTextBox.Name = "sitePathTextBox";
            this.sitePathTextBox.Size = new System.Drawing.Size(254, 19);
            this.sitePathTextBox.TabIndex = 7;
            // 
            // sitePathBrowseButton
            // 
            this.sitePathBrowseButton.Location = new System.Drawing.Point(421, 342);
            this.sitePathBrowseButton.Name = "sitePathBrowseButton";
            this.sitePathBrowseButton.Size = new System.Drawing.Size(57, 23);
            this.sitePathBrowseButton.TabIndex = 8;
            this.sitePathBrowseButton.Text = "開く";
            this.sitePathBrowseButton.UseVisualStyleBackColor = true;
            this.sitePathBrowseButton.Click += new System.EventHandler(this.sitePathBrowseButton_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(13, 413);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(152, 12);
            this.label5.TabIndex = 10;
            this.label5.Text = "デフォルトの配信通知メッセージ";
            // 
            // defaultPushMessageTextBox
            // 
            this.defaultPushMessageTextBox.Location = new System.Drawing.Point(15, 428);
            this.defaultPushMessageTextBox.Multiline = true;
            this.defaultPushMessageTextBox.Name = "defaultPushMessageTextBox";
            this.defaultPushMessageTextBox.Size = new System.Drawing.Size(463, 65);
            this.defaultPushMessageTextBox.TabIndex = 11;
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(402, 500);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(75, 23);
            this.cancelButton.TabIndex = 13;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // okButton
            // 
            this.okButton.Location = new System.Drawing.Point(321, 500);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(75, 23);
            this.okButton.TabIndex = 12;
            this.okButton.Text = "OK";
            this.okButton.UseVisualStyleBackColor = true;
            this.okButton.Click += new System.EventHandler(this.okButton_Click);
            // 
            // sitePathBrowserDialog
            // 
            this.sitePathBrowserDialog.Description = "配信サイトの物理パス";
            this.sitePathBrowserDialog.ShowNewFolderButton = false;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(50, 381);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(105, 12);
            this.label6.TabIndex = 14;
            this.label6.Text = "更新元フォルダのパス";
            // 
            // standByPathTextBox
            // 
            this.standByPathTextBox.Location = new System.Drawing.Point(161, 378);
            this.standByPathTextBox.Name = "standByPathTextBox";
            this.standByPathTextBox.Size = new System.Drawing.Size(254, 19);
            this.standByPathTextBox.TabIndex = 9;
            // 
            // standByPathButton
            // 
            this.standByPathButton.Location = new System.Drawing.Point(421, 376);
            this.standByPathButton.Name = "standByPathButton";
            this.standByPathButton.Size = new System.Drawing.Size(57, 23);
            this.standByPathButton.TabIndex = 10;
            this.standByPathButton.Text = "開く";
            this.standByPathButton.UseVisualStyleBackColor = true;
            this.standByPathButton.Click += new System.EventHandler(this.standByPathButton_Click);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(12, 9);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(98, 12);
            this.label7.TabIndex = 17;
            this.label7.Text = "配信タイトルの名前";
            // 
            // titleNameTextBox
            // 
            this.titleNameTextBox.Location = new System.Drawing.Point(118, 6);
            this.titleNameTextBox.Name = "titleNameTextBox";
            this.titleNameTextBox.Size = new System.Drawing.Size(360, 19);
            this.titleNameTextBox.TabIndex = 0;
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(14, 130);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(197, 12);
            this.label8.TabIndex = 18;
            this.label8.Text = "Android版配信購読アプリのパッケージ名";
            // 
            // lvlPackageNameTextBox
            // 
            this.lvlPackageNameTextBox.Location = new System.Drawing.Point(217, 127);
            this.lvlPackageNameTextBox.Name = "lvlPackageNameTextBox";
            this.lvlPackageNameTextBox.Size = new System.Drawing.Size(261, 19);
            this.lvlPackageNameTextBox.TabIndex = 5;
            // 
            // apnsIsSandboxCheckBox
            // 
            this.apnsIsSandboxCheckBox.AutoSize = true;
            this.apnsIsSandboxCheckBox.Checked = true;
            this.apnsIsSandboxCheckBox.CheckState = System.Windows.Forms.CheckState.Checked;
            this.apnsIsSandboxCheckBox.Location = new System.Drawing.Point(14, 97);
            this.apnsIsSandboxCheckBox.Name = "apnsIsSandboxCheckBox";
            this.apnsIsSandboxCheckBox.Size = new System.Drawing.Size(175, 16);
            this.apnsIsSandboxCheckBox.TabIndex = 4;
            this.apnsIsSandboxCheckBox.Text = "APNsはサンドボックスとして動作";
            this.apnsIsSandboxCheckBox.UseVisualStyleBackColor = true;
            // 
            // EditTitleForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(490, 538);
            this.Controls.Add(this.apnsIsSandboxCheckBox);
            this.Controls.Add(this.lvlPackageNameTextBox);
            this.Controls.Add(this.label8);
            this.Controls.Add(this.titleNameTextBox);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.standByPathButton);
            this.Controls.Add(this.standByPathTextBox);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.defaultPushMessageTextBox);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.sitePathBrowseButton);
            this.Controls.Add(this.sitePathTextBox);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.lvlPublikKeyTextBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.apnsFilePasswordTextBox);
            this.Controls.Add(this.apnsFileBrowseButton);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.apnsFilePathTextBox);
            this.Name = "EditTitleForm";
            this.Text = "配信タイトル";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog apnsFileDialog;
        private System.Windows.Forms.TextBox apnsFilePathTextBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button apnsFileBrowseButton;
        private System.Windows.Forms.TextBox apnsFilePasswordTextBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox lvlPublikKeyTextBox;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox sitePathTextBox;
        private System.Windows.Forms.Button sitePathBrowseButton;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox defaultPushMessageTextBox;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button okButton;
        private System.Windows.Forms.FolderBrowserDialog sitePathBrowserDialog;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox standByPathTextBox;
        private System.Windows.Forms.Button standByPathButton;
        private System.Windows.Forms.FolderBrowserDialog standByPathBrowserDialog;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.TextBox titleNameTextBox;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.TextBox lvlPackageNameTextBox;
        private System.Windows.Forms.CheckBox apnsIsSandboxCheckBox;
    }
}