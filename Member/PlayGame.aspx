<%@ Page Title="Play game" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PlayGame.aspx.cs" Inherits="LearningSystem.Member.PlayGame" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false">Preview — no attempt is saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></asp:Panel>
<p class="preserve-lines"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p><p>Template: <asp:Literal ID="litTemplate" runat="server" Mode="Encode" /></p>
<asp:Panel ID="pnlResult" runat="server" Visible="false"><h2>Game result</h2><p><asp:Literal ID="litResultContext" runat="server" Mode="Encode" /></p><p>Score: <strong><asp:Literal ID="litScore" runat="server" Mode="Encode" /></strong> · <asp:Literal ID="litSeconds" runat="server" Mode="Encode" /></p></asp:Panel>
<asp:Button ID="btnStart" runat="server" Text="Start / play again" ValidationGroup="Start" OnClick="StartGame" />
<asp:Panel ID="pnlPlay" runat="server" Visible="false"><h2>Play</h2><noscript>JavaScript is required for these interactive games. Enable it and start again.</noscript>
<asp:ValidationSummary ID="vsResult" runat="server" ValidationGroup="Result" /><asp:CustomValidator ID="cvResult" runat="server" ValidationGroup="Result" OnServerValidate="ValidateResult" ErrorMessage="Complete the game and submit a valid result." />
<asp:HiddenField ID="hfRun" runat="server" /><asp:HiddenField ID="hfResult" runat="server" ClientIDMode="Static" />
<asp:Literal ID="litGame" runat="server" />
<asp:Button ID="btnSubmit" runat="server" Text="Submit result" ValidationGroup="Result" OnClick="SubmitGame" OnClientClick="if (!window.learningGame || !window.learningGame.prepare()) return false;" />
</asp:Panel>
<div class="actions"><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /><asp:HyperLink ID="lnkBack" runat="server" Text="Back to course / activities" /></div>
<asp:Panel ID="pnlHistory" runat="server"><h2>Your attempts</h2><p><asp:Literal ID="litBest" runat="server" Mode="Encode" /></p>
<div class="table-scroll" role="region" aria-label="Your game attempt history" tabindex="0"><asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" Caption="Your game attempt history" UseAccessibleHeader="true" EmptyDataText="No attempts yet."><Columns><asp:BoundField DataField="SubmittedAt" HeaderText="Submitted (UTC)" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" /><asp:BoundField DataField="ScorePercent" HeaderText="Score (%)" DataFormatString="{0:F2}" /><asp:BoundField DataField="TimeTakenSeconds" HeaderText="Time (seconds)" /><asp:HyperLinkField Text="View result" DataNavigateUrlFields="ReviewUrl" HeaderText="Result" /></Columns></asp:GridView></div></asp:Panel>
<script src="<%= ResolveUrl("~/Scripts/games.js") %>"></script>
<p><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="My results" Visible="false" /></p>
</asp:Content>



