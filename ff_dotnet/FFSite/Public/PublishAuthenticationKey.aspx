<%@ Page Language="C#" AutoEventWireup="true"%>
<%@ Import namespace="FFCommon" %>
<%@ Import namespace="FFCommon.DataSetTableAdapters" %>
<%@ Import namespace="FFSite" %>
<%@ Import namespace="System.Net" %>
<script runat="server">
    private static readonly log4net.ILog logger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.Cookies[SiteConstant.AuthTokenCookieName] == null)
        {
            Publish();
        }
        else
        {
            string tokenBody = Request.Cookies[SiteConstant.AuthTokenCookieName].Value;
            TokenVerifier v = new TokenVerifier(tokenBody, DateTime.Now);
            if (!v.IsValid)
            {
                Publish();
            }
            else
            {
                AuthKeyLabel.Text = v.Subscriber.AuthenticationKey;
            }
        }
    }

    private void Publish()
    {
        DataSet.SubscriberRow subscriber = Util.PublishSubscriber(AuthScheme.Web);
        AuthKeyLabel.Text = subscriber.AuthenticationKey;

        TokenPublisher p = new TokenPublisher(subscriber, DateTime.Now);
        DataSet.TokenRow t;
        try
        {
            t = p.Publish();
        }
        catch (Exception ex)
        {
            logger.Error("認証トークンの発行に失敗しました", ex);
            Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            Response.End();
            return;
        }
        HttpCookie cookie = new HttpCookie(SiteConstant.AuthTokenCookieName, t.Body);
        cookie.Expires = DateTime.MaxValue;
        Response.Cookies.Add(cookie);
    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>認証キーの発行</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <h1>認証キーを発行しました</h1>
        <p>
            認証キー：<span style="font-size:x-large;font-family:monospace;">
            <asp:Label ID="AuthKeyLabel" runat="server" Text="Label"></asp:Label></span></p>
        <p>　認証キーを用いる場合には、<a href="../Auth/">こちら</a>のアドレスをご利用ください。</p>
    </div>
    </form>
</body>
</html>
