<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AskAuthenticationKey.aspx.cs" Inherits="FFSite.AskAuthenticationKey" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>認証キーを入力してください</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <h1>認証キーを入力してください</h1>
        <p>
            認証キー
            <asp:TextBox ID="AuthenticationKeyTextBox" runat="server" Width="321px"></asp:TextBox>
            <asp:Button ID="OKButton" runat="server" Text="OK" OnClick="OKButton_Click" /><asp:Label
                ID="InvalidKeyLabel" runat="server" Text=""></asp:Label></p>
    </div>
    </form>
</body>
</html>
