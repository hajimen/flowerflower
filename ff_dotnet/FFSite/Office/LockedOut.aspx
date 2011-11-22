<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LockedOut.aspx.cs" Inherits="FFSite.LockedOut" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>このアカウントを一時的に閉鎖しています</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <h1>このアカウントを一時的に閉鎖しています</h1>
    <p>このアカウントに対して短期間に多数のブラウザからアクセスがあったため、このアカウントを一時的に閉鎖しています。<asp:Label ID="LockoutUntilLabel" runat="server"
            Text="2011年10月13日9時14分"></asp:Label>ごろから再びご利用いただける見込みです。</p>
    <p>注意：このアカウントの認証キーが第三者に漏れて不正に利用されている可能性があります。その場合、これからもたびたびこのアカウントを一時的に閉鎖するかもしれません。</p>
    </div>
    </form>
</body>
</html>
