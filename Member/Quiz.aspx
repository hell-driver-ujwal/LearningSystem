<%@ Page Title="Quiz" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="LearningSystem.Member.Quiz" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false">Preview — no attempts or answers are saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></asp:Panel>
<p class="preserve-lines"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
<asp:ValidationSummary ID="vsQuiz" runat="server" />
<asp:Panel ID="pnlIntro" runat="server"><p><asp:Literal ID="litIntro" runat="server" Mode="Encode" /></p><asp:Button ID="btnStart" runat="server" Text="Start quiz" OnClick="StartQuiz" /></asp:Panel>
<asp:Panel ID="pnlPlay" runat="server" Visible="false">
<asp:HiddenField ID="hfRun" runat="server" />
<asp:Literal ID="litTimer" runat="server" /><asp:Literal ID="litQuestions" runat="server" />
<asp:Button ID="btnSubmit" runat="server" Text="Submit quiz" OnClick="SubmitQuiz" />
</asp:Panel>
<asp:Literal ID="litFeedback" runat="server" />
<div class="actions"><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /><asp:HyperLink ID="lnkBack" runat="server" Text="Back to course / activities" /></div>
<script src="<%= ResolveUrl("~/Scripts/quiz.js") %>"></script>
</asp:Content>
