<%@ Page Title="Quiz result" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs" Inherits="LearningSystem.Member.QuizResult" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<p><asp:Literal ID="litDate" runat="server" Mode="Encode" /></p>
<asp:Literal ID="litReview" runat="server" />
<div class="actions"><asp:HyperLink ID="lnkRetry" runat="server" Text="Try again / quiz intro" /><asp:HyperLink ID="lnkBack" runat="server" Text="Back to course / activities" /></div>
<p><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="My results" Visible="false" /></p>
</asp:Content>

