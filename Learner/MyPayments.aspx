<%@ Page Title="My payments" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyPayments.aspx.cs" Inherits="LearningSystem.Learner.MyPayments" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>My payments</h1><p class="intro">Your eSewa payments for paid courses.</p></div></div>
<p class="sandbox-notice">Payments use the built-in eSewa demo screen. No real money is charged.</p>
<div class="filter-bar"><asp:Label ID="lblStatus" runat="server" AssociatedControlID="ddlStatus" Text="Status" />
<asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter"><asp:ListItem Value="">All</asp:ListItem><asp:ListItem>Pending</asp:ListItem><asp:ListItem>Complete</asp:ListItem><asp:ListItem>Failed</asp:ListItem><asp:ListItem>Canceled</asp:ListItem></asp:DropDownList></div>
<div class="table-scroll" role="region" aria-label="Payment history" tabindex="0">
<asp:GridView ID="gvPayments" runat="server" AutoGenerateColumns="false" AllowPaging="true" PageSize="15" OnPageIndexChanging="PageChanged" Caption="Payment history (dates in UTC)" EmptyDataText="No payments match your selection." UseAccessibleHeader="true"><Columns>
<asp:BoundField DataField="CourseTitle" HeaderText="Course" HtmlEncode="true" />
<asp:BoundField DataField="AmountNPR" HeaderText="Amount (NPR)" DataFormatString="{0:N2}" HtmlEncode="true" />
<asp:BoundField DataField="Provider" HeaderText="Provider" HtmlEncode="true" />
<asp:BoundField DataField="Status" HeaderText="Status" HtmlEncode="true" />
<asp:BoundField DataField="CreatedDate" HeaderText="Initiated (UTC)" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />
<asp:BoundField DataField="VerifiedDate" HeaderText="Verified (UTC)" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" NullDisplayText="Not verified" />
<asp:BoundField DataField="ProviderReference" HeaderText="Provider reference" HtmlEncode="true" />
</Columns></asp:GridView></div><p><a href="Dashboard.aspx">Back to dashboard</a></p>
</asp:Content>
