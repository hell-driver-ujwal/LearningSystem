<%@ Page Title="Scenario" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Scenario.aspx.cs" Inherits="LearningSystem.Member.Scenario" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner">Teacher/admin preview — results are not saved. No learner attempt is created.</asp:Panel>
<p class="preserve-lines"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
<asp:ValidationSummary ID="vsAction" runat="server" ValidationGroup="Action" />
<asp:Panel ID="pnlStep" runat="server" Visible="false" CssClass="topic-card">
<h2>Current step</h2><p class="preserve-lines"><asp:Literal ID="litStep" runat="server" Mode="Encode" /></p>
<asp:Literal ID="litImage" runat="server" EnableViewState="false" />
<asp:Panel ID="pnlChoices" runat="server"><h3>Choose what to do</h3>
<asp:Label ID="lblNoChoices" runat="server" Visible="false" Text="No choices are configured for this draft step. Restart or return to the builder." />
<asp:Repeater ID="rptChoices" runat="server" OnItemCommand="Choose"><ItemTemplate><div class="actions"><asp:Button ID="btnChoice" runat="server" Text='<%# Eval("ChoiceText") %>' CommandName="Choose" CommandArgument='<%# Eval("ChoiceID") %>' ValidationGroup="Action" /></div></ItemTemplate></asp:Repeater>
</asp:Panel>
<asp:Panel ID="pnlEnding" runat="server" Visible="false"><h3>Outcome: <asp:Literal ID="litOutcome" runat="server" Mode="Encode" /></h3><p class="preserve-lines"><asp:Literal ID="litFeedback" runat="server" Mode="Encode" /></p><p><asp:Literal ID="litSaved" runat="server" Mode="Encode" /></p><asp:Button ID="btnFinish" runat="server" Text="Finish scenario" ValidationGroup="Action" OnClick="Finish" /></asp:Panel>
</asp:Panel>
<div class="actions"><asp:Button ID="btnStart" runat="server" Text="Start scenario" ValidationGroup="Action" OnClick="Start" /><asp:Button ID="btnCancel" runat="server" Text="Cancel / return to course" CausesValidation="false" OnClick="Cancel" /></div>
<p><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="My results" Visible="false" /></p>
</asp:Content>

