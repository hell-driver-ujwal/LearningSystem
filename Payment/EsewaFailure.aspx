<%@ Page Title="Payment verification" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EsewaFailure.aspx.cs" Inherits="LearningSystem.Payment.EsewaFailure" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Payment verification</h1>
<p class="sandbox-notice">eSewa sandbox test mode</p>
<p>No access is granted until payment verification succeeds. If verification is unavailable, keep your signed return URL and try it later.</p>
<p><a href="../Learner/MyPayments.aspx">My payments</a> · <a href="../Courses.aspx">Back to courses</a></p>
</asp:Content>
