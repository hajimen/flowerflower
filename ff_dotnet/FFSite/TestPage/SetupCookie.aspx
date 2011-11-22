<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetupCookie.aspx.cs" Inherits="FFSite.TestPage.SetupCookie" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>テスト用クッキーの設定</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <h1>テスト用クッキーの設定</h1>
        <p>
            <asp:Button ID="CleanUpButton" runat="server" OnClick="CleanUpButton_Click" Text="Clean Up" />&nbsp;</p>
    
    </div>
    </form>
</body>
</html>
