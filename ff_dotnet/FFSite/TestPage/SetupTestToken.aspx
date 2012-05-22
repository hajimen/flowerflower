<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetupTestToken.aspx.cs" Inherits="FFSite.TestPage.SetupTestToken" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>テスト用認証トークンの設定</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <h1>テスト用認証トークンの設定</h1>
        <p>
            <asp:Button ID="OutdateButton" runat="server" OnClick="OutdateButton_Click" Text="Outdate" />&nbsp;</p>
        <p>
            <asp:Button ID="LivingButton" runat="server" OnClick="LivingButton_Click" Text="Living" />&nbsp;</p>
        <p>
            <asp:Button ID="NotUsedButton" runat="server" OnClick="NotUsedButton_Click" Text="Not Used" />&nbsp;</p>
        <p>
            <asp:Button ID="CleanUpButton" runat="server" OnClick="CleanUpButton_Click" Text="Clean Up" />&nbsp;</p>
        <p>
            <asp:Button ID="BeforeLockoutButton" runat="server" OnClick="BeforeLockoutButton_Click"
                Text="Before Lockout" />&nbsp;</p>
    
    </div>
    </form>
</body>
</html>
