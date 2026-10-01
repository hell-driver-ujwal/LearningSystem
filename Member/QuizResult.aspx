<%@ Page Title="Quiz result" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs" Inherits="LearningSystem.Member.QuizResult" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("Quiz") %><div><p class="eyebrow">Quiz result</p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1><p class="muted"><asp:Literal ID="litDate" runat="server" Mode="Encode" /></p></div></div>
<asp:Literal ID="litReview" runat="server" />
<div class="actions"><asp:HyperLink ID="lnkRetry" runat="server" Text="Try again" CssClass="button" /><asp:HyperLink ID="lnkBack" runat="server" Text="Back to the course" /><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="All my results" Visible="false" /></div>
</asp:Content>
