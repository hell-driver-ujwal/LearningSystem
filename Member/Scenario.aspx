<%@ Page Title="Scenario" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Scenario.aspx.cs" Inherits="LearningSystem.Member.Scenario" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner"><span>Preview mode. Your choices are not saved and no learner attempt is created.</span></asp:Panel>
<div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("Scenario") %><div><p class="eyebrow">Decision scenario</p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1></div></div>
<p class="preserve-lines intro"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
<asp:ValidationSummary ID="vsAction" runat="server" ValidationGroup="Action" />
<asp:Panel ID="pnlStep" runat="server" Visible="false" CssClass="scenario-stage">
    <h2 class="visually-hidden">Current step</h2>
    <asp:Literal ID="litImage" runat="server" EnableViewState="false" />
    <p class="step-text preserve-lines"><asp:Literal ID="litStep" runat="server" Mode="Encode" /></p>
    <asp:Panel ID="pnlChoices" runat="server">
        <h3>What do you do?</h3>
        <asp:Label ID="lblNoChoices" runat="server" Visible="false" Text="No choices are set up for this draft step yet. Restart, or return to the scenario builder." />
        <div class="choice-list"><asp:Repeater ID="rptChoices" runat="server" OnItemCommand="Choose"><ItemTemplate><div class="actions"><asp:Button ID="btnChoice" runat="server" Text='<%# Eval("ChoiceText") %>' CommandName="Choose" CommandArgument='<%# Eval("ChoiceID") %>' ValidationGroup="Action" /></div></ItemTemplate></asp:Repeater></div>
    </asp:Panel>
    <asp:Panel ID="pnlEnding" runat="server" Visible="false" CssClass="outcome">
        <asp:Literal ID="litEndingArt" runat="server" />
        <h3>Outcome: <asp:Literal ID="litOutcome" runat="server" Mode="Encode" /></h3>
        <p class="preserve-lines"><asp:Literal ID="litFeedback" runat="server" Mode="Encode" /></p>
        <p class="muted"><small><asp:Literal ID="litSaved" runat="server" Mode="Encode" /></small></p>
        <asp:Button ID="btnFinish" runat="server" Text="Finish and save outcome" ValidationGroup="Action" OnClick="Finish" CssClass="accent" />
    </asp:Panel>
</asp:Panel>
<div class="actions"><asp:Button ID="btnStart" runat="server" Text="Start scenario" ValidationGroup="Action" OnClick="Start" CssClass="accent" /><asp:Button ID="btnCancel" runat="server" Text="Back to course" CausesValidation="false" OnClick="Cancel" CssClass="secondary" /><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="All my results" Visible="false" /></div>
</asp:Content>
