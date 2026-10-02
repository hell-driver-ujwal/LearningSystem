<%@ Page Title="Quiz" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="LearningSystem.Member.Quiz" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false"><span>Preview mode. No attempt or answers are saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></span></asp:Panel>
<div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("Quiz") %><div><p class="eyebrow">Quiz</p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1></div></div>
<p class="preserve-lines intro"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
<asp:ValidationSummary ID="vsQuiz" runat="server" />
<asp:Panel ID="pnlIntro" runat="server" CssClass="start-panel">
    <asp:Literal ID="litIntro" runat="server" />
    <asp:Button ID="btnStart" runat="server" Text="Start quiz" OnClick="StartQuiz" CssClass="large accent" />
    <%= LearningSystem.Helpers.MascotHelper.Render("think") %>
</asp:Panel>
<asp:Panel ID="pnlPlay" runat="server" Visible="false">
    <asp:HiddenField ID="hfRun" runat="server" />
    <asp:Literal ID="litTimer" runat="server" /><asp:Literal ID="litQuestions" runat="server" />
    <div class="actions"><asp:Button ID="btnSubmit" runat="server" Text="Submit answers" OnClick="SubmitQuiz" CssClass="large" OnClientClick="return window.quizConfirm ? window.quizConfirm() : true;" /></div>
</asp:Panel>
<asp:Literal ID="litFeedback" runat="server" />
<div class="actions"><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /><asp:HyperLink ID="lnkBack" runat="server" Text="Back to the course" /></div>
<script src="<%: LearningSystem.Helpers.UiHelper.AssetUrl("~/Scripts/quiz.js") %>"></script>
</asp:Content>
