<%@ Page Title="Play game" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PlayGame.aspx.cs" Inherits="LearningSystem.Member.PlayGame" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false"><span>Preview mode. Results are shown but never saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></span></asp:Panel>
<div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("Game") %><div><p class="eyebrow">Game: <asp:Literal ID="litTemplate" runat="server" Mode="Encode" /></p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1></div></div>
<p class="preserve-lines intro"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
<asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="result-panel">
    <asp:Literal ID="litRing" runat="server" />
    <div><h2>Score: <asp:Literal ID="litScore" runat="server" Mode="Encode" /></h2><p><asp:Literal ID="litSeconds" runat="server" Mode="Encode" /></p><p class="muted"><small><asp:Literal ID="litResultContext" runat="server" Mode="Encode" /></small></p></div>
</asp:Panel>
<asp:Panel ID="pnlStart" runat="server" CssClass="start-panel">
    <p><asp:Literal ID="litHowTo" runat="server" Mode="Encode" /></p>
    <asp:Button ID="btnStart" runat="server" Text="Start game" ValidationGroup="Start" OnClick="StartGame" CssClass="large accent" />
    <%= LearningSystem.Helpers.MascotHelper.Render("wave") %>
</asp:Panel>
<asp:Panel ID="pnlPlay" runat="server" Visible="false" CssClass="game-shell">
    <h2 class="visually-hidden">Play</h2>
    <noscript><p class="message error">This game needs JavaScript. Turn it on in your browser, then start again.</p></noscript>
    <asp:ValidationSummary ID="vsResult" runat="server" ValidationGroup="Result" /><asp:CustomValidator ID="cvResult" runat="server" ValidationGroup="Result" OnServerValidate="ValidateResult" ErrorMessage="Finish the game, then submit your result." Display="None" />
    <%-- Poses Inky uses while coaching the game (games.js copies them) --%>
    <div id="inky-poses" hidden><%= LearningSystem.Helpers.MascotHelper.Render("think") %><%= LearningSystem.Helpers.MascotHelper.Render("cheer") %><%= LearningSystem.Helpers.MascotHelper.Render("oops") %><%= LearningSystem.Helpers.MascotHelper.Render("trophy") %><%= LearningSystem.Helpers.MascotHelper.Render("wave") %></div>
    <asp:HiddenField ID="hfRun" runat="server" /><asp:HiddenField ID="hfResult" runat="server" ClientIDMode="Static" />
    <asp:Literal ID="litGame" runat="server" />
    <div class="actions submit-row"><asp:Button ID="btnSubmit" runat="server" Text="Save my score" ValidationGroup="Result" OnClick="SubmitGame" OnClientClick="if (!window.learningGame || !window.learningGame.prepare()) return false;" CssClass="large" /></div>
</asp:Panel>
<div class="actions"><asp:Button ID="btnCancel" runat="server" Text="Back to course" CausesValidation="false" OnClick="Cancel" CssClass="secondary" /><asp:HyperLink ID="lnkBack" runat="server" Text="Course outline" /><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="All my results" Visible="false" /></div>
<asp:Panel ID="pnlHistory" runat="server" CssClass="section"><h2>Your attempts</h2><p><asp:Literal ID="litBest" runat="server" Mode="Encode" /></p>
<div class="table-scroll" role="region" aria-label="Your game attempt history" tabindex="0"><asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" Caption="Your game attempt history" UseAccessibleHeader="true" EmptyDataText="No attempts yet. Your scores appear here after you submit."><Columns><asp:BoundField DataField="SubmittedAt" HeaderText="Submitted (UTC)" DataFormatString="{0:d MMM yyyy, HH:mm}" /><asp:BoundField DataField="ScorePercent" HeaderText="Score (%)" DataFormatString="{0:0.##}" /><asp:BoundField DataField="TimeTakenSeconds" HeaderText="Time (seconds)" /><asp:HyperLinkField Text="View result" DataNavigateUrlFields="ReviewUrl" HeaderText="Result" /></Columns></asp:GridView></div></asp:Panel>
<script src="<%: LearningSystem.Helpers.UiHelper.AssetUrl("~/Scripts/games.js") %>"></script>
</asp:Content>
