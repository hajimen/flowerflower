namespace FFConfig
{
    partial class TitleListForm
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
            this.components = new System.ComponentModel.Container();
            this.titleDataGridView = new System.Windows.Forms.DataGridView();
            this.idDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.nameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.pushMessageDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.siteRootPathDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.standByPathDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.titleBindingSource = new System.Windows.Forms.BindingSource(this.components);
            this.dataSet = new FFCommon.DataSet();
            this.titleTableAdapter = new FFCommon.DataSetTableAdapters.TitleTableAdapter();
            this.closeButton = new System.Windows.Forms.Button();
            this.newTitleButton = new System.Windows.Forms.Button();
            this.deleteTitleButton = new System.Windows.Forms.Button();
            this.editTitleButton = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.titleDataGridView)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.titleBindingSource)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dataSet)).BeginInit();
            this.SuspendLayout();
            // 
            // titleDataGridView
            // 
            this.titleDataGridView.AutoGenerateColumns = false;
            this.titleDataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.titleDataGridView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.idDataGridViewTextBoxColumn,
            this.nameDataGridViewTextBoxColumn,
            this.pushMessageDataGridViewTextBoxColumn,
            this.siteRootPathDataGridViewTextBoxColumn,
            this.standByPathDataGridViewTextBoxColumn});
            this.titleDataGridView.DataSource = this.titleBindingSource;
            this.titleDataGridView.Location = new System.Drawing.Point(12, 12);
            this.titleDataGridView.Name = "titleDataGridView";
            this.titleDataGridView.RowTemplate.Height = 21;
            this.titleDataGridView.Size = new System.Drawing.Size(605, 359);
            this.titleDataGridView.TabIndex = 0;
            // 
            // idDataGridViewTextBoxColumn
            // 
            this.idDataGridViewTextBoxColumn.DataPropertyName = "Id";
            this.idDataGridViewTextBoxColumn.HeaderText = "Id";
            this.idDataGridViewTextBoxColumn.Name = "idDataGridViewTextBoxColumn";
            this.idDataGridViewTextBoxColumn.ReadOnly = true;
            this.idDataGridViewTextBoxColumn.Width = 70;
            // 
            // nameDataGridViewTextBoxColumn
            // 
            this.nameDataGridViewTextBoxColumn.DataPropertyName = "Name";
            this.nameDataGridViewTextBoxColumn.HeaderText = "Name";
            this.nameDataGridViewTextBoxColumn.Name = "nameDataGridViewTextBoxColumn";
            // 
            // pushMessageDataGridViewTextBoxColumn
            // 
            this.pushMessageDataGridViewTextBoxColumn.DataPropertyName = "PushMessage";
            this.pushMessageDataGridViewTextBoxColumn.HeaderText = "PushMessage";
            this.pushMessageDataGridViewTextBoxColumn.Name = "pushMessageDataGridViewTextBoxColumn";
            this.pushMessageDataGridViewTextBoxColumn.Width = 160;
            // 
            // siteRootPathDataGridViewTextBoxColumn
            // 
            this.siteRootPathDataGridViewTextBoxColumn.DataPropertyName = "SiteRootPath";
            this.siteRootPathDataGridViewTextBoxColumn.HeaderText = "SiteRootPath";
            this.siteRootPathDataGridViewTextBoxColumn.Name = "siteRootPathDataGridViewTextBoxColumn";
            // 
            // standByPathDataGridViewTextBoxColumn
            // 
            this.standByPathDataGridViewTextBoxColumn.DataPropertyName = "StandByPath";
            this.standByPathDataGridViewTextBoxColumn.HeaderText = "StandByPath";
            this.standByPathDataGridViewTextBoxColumn.Name = "standByPathDataGridViewTextBoxColumn";
            // 
            // titleBindingSource
            // 
            this.titleBindingSource.DataMember = "Title";
            this.titleBindingSource.DataSource = this.dataSet;
            // 
            // dataSet
            // 
            this.dataSet.DataSetName = "DataSet";
            this.dataSet.SchemaSerializationMode = System.Data.SchemaSerializationMode.IncludeSchema;
            // 
            // titleTableAdapter
            // 
            this.titleTableAdapter.ClearBeforeFill = true;
            // 
            // closeButton
            // 
            this.closeButton.Location = new System.Drawing.Point(542, 377);
            this.closeButton.Name = "closeButton";
            this.closeButton.Size = new System.Drawing.Size(75, 23);
            this.closeButton.TabIndex = 1;
            this.closeButton.Text = "閉じる";
            this.closeButton.UseVisualStyleBackColor = true;
            this.closeButton.Click += new System.EventHandler(this.CloseButton_Click);
            // 
            // newTitleButton
            // 
            this.newTitleButton.Location = new System.Drawing.Point(13, 377);
            this.newTitleButton.Name = "newTitleButton";
            this.newTitleButton.Size = new System.Drawing.Size(145, 23);
            this.newTitleButton.TabIndex = 2;
            this.newTitleButton.Text = "配信タイトルを追加";
            this.newTitleButton.UseVisualStyleBackColor = true;
            this.newTitleButton.Click += new System.EventHandler(this.NewTitleButton_Click);
            // 
            // deleteTitleButton
            // 
            this.deleteTitleButton.Location = new System.Drawing.Point(245, 377);
            this.deleteTitleButton.Name = "deleteTitleButton";
            this.deleteTitleButton.Size = new System.Drawing.Size(75, 23);
            this.deleteTitleButton.TabIndex = 3;
            this.deleteTitleButton.Text = "削除";
            this.deleteTitleButton.UseVisualStyleBackColor = true;
            this.deleteTitleButton.Click += new System.EventHandler(this.deleteTitleButton_Click);
            // 
            // editTitleButton
            // 
            this.editTitleButton.Location = new System.Drawing.Point(164, 377);
            this.editTitleButton.Name = "editTitleButton";
            this.editTitleButton.Size = new System.Drawing.Size(75, 23);
            this.editTitleButton.TabIndex = 4;
            this.editTitleButton.Text = "編集";
            this.editTitleButton.UseVisualStyleBackColor = true;
            this.editTitleButton.Click += new System.EventHandler(this.editTitleButton_Click);
            // 
            // TitleListForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(629, 412);
            this.Controls.Add(this.editTitleButton);
            this.Controls.Add(this.deleteTitleButton);
            this.Controls.Add(this.newTitleButton);
            this.Controls.Add(this.closeButton);
            this.Controls.Add(this.titleDataGridView);
            this.Name = "TitleListForm";
            this.Text = "配信タイトル";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.titleDataGridView)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.titleBindingSource)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dataSet)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView titleDataGridView;
        private FFCommon.DataSet dataSet;
        private System.Windows.Forms.BindingSource titleBindingSource;
        private FFCommon.DataSetTableAdapters.TitleTableAdapter titleTableAdapter;
        private System.Windows.Forms.DataGridViewTextBoxColumn idDataGridViewTextBoxColumn;
        private System.Windows.Forms.DataGridViewTextBoxColumn nameDataGridViewTextBoxColumn;
        private System.Windows.Forms.DataGridViewTextBoxColumn pushMessageDataGridViewTextBoxColumn;
        private System.Windows.Forms.DataGridViewTextBoxColumn siteRootPathDataGridViewTextBoxColumn;
        private System.Windows.Forms.DataGridViewTextBoxColumn standByPathDataGridViewTextBoxColumn;
        private System.Windows.Forms.Button closeButton;
        private System.Windows.Forms.Button newTitleButton;
        private System.Windows.Forms.Button deleteTitleButton;
        private System.Windows.Forms.Button editTitleButton;
    }
}