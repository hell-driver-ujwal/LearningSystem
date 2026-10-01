<%@ Page Title="Self-assessment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SelfAssessment.aspx.cs" Inherits="LearningSystem.Member.SelfAssessment" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false"><span>Preview mode. No ratings are saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></span></asp:Panel>
<div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("SelfAssessment") %><div><p class="eyebrow">Self-assessment</p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1></div></div>
<p class="preserve-lines intro"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
<asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="result-panel">
    <%= LearningSystem.Helpers.UiHelper.TypeMark("SelfAssessment") %>
    <div><h2>Your confidence: <asp:Literal ID="litAverage" runat="server" Mode="Encode" /> (<asp:Literal ID="litLevel" runat="server" Mode="Encode" />)</h2>
    <p><asp:Literal ID="litFeedback" runat="server" Mode="Encode" /></p><p class="muted"><small><asp:Literal ID="litResultContext" runat="server" Mode="Encode" /></small></p></div>
</asp:Panel>
<asp:Panel ID="pnlResponses" runat="server"><div class="table-scroll" role="region" aria-label="Your saved statement ratings" tabindex="0"><asp:GridView ID="gvResponses" runat="server" AutoGenerateColumns="false" Caption="Your saved statement ratings" EmptyDataText="Submit an assessment to see your ratings here." UseAccessibleHeader="true"><Columns><asp:BoundField DataField="StatementText" HeaderText="Statement" HtmlEncode="true" /><asp:BoundField DataField="Rating" HeaderText="Rating out of 5" /></Columns></asp:GridView></div></asp:Panel>
<section class="form-card wide" aria-labelledby="rate-title">
    <h2 id="rate-title">Rate your confidence</h2>
    <p class="muted">1 means "not yet confident" and 5 means "very confident". These ratings are for your own reflection and are never turned into a score.</p>
    <asp:ValidationSummary ID="vsRatings" runat="server" ValidationGroup="Ratings" />
    <asp:CustomValidator ID="cvRatings" runat="server" ValidationGroup="Ratings" OnServerValidate="ValidateRatings" ErrorMessage="Rate every statement with a whole number from 1 to 5." Display="None" />
    <asp:Label ID="lblEmpty" runat="server" CssClass="empty-state" Text="No statements are available yet." />
    <asp:Repeater ID="rptStatements" runat="server"><ItemTemplate>
        <fieldset class="statement">
            <legend class="field-label"><%#: Eval("StatementText") %></legend>
            <asp:HiddenField ID="hfStatement" runat="server" Value='<%# Eval("StatementID") %>' />
            <asp:RadioButtonList ID="ddlRating" runat="server" RepeatLayout="Flow" RepeatDirection="Horizontal" CssClass="rating-scale">
                <asp:ListItem Value="1">1</asp:ListItem><asp:ListItem Value="2">2</asp:ListItem><asp:ListItem Value="3">3</asp:ListItem><asp:ListItem Value="4">4</asp:ListItem><asp:ListItem Value="5">5</asp:ListItem>
            </asp:RadioButtonList>
            <div class="rating-ends" aria-hidden="true"><span>Not yet confident</span><span>Very confident</span></div>
            <asp:RequiredFieldValidator ID="rfvRating" runat="server" ControlToValidate="ddlRating" ValidationGroup="Ratings" ErrorMessage='<%# "Choose a rating for: " + Eval("StatementText") %>' Display="Dynamic" Text="Choose a rating." />
        </fieldset>
    </ItemTemplate></asp:Repeater>
    <div class="actions"><asp:Button ID="btnSubmit" runat="server" Text="Submit self-assessment" ValidationGroup="Ratings" OnClick="SubmitAssessment" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /></div>
</section>
<asp:Panel ID="pnlHistory" runat="server" CssClass="section">
    <h2>Your earlier self-assessments</h2><p class="muted">Compare your confidence over time. Each row is one submitted assessment.</p>
    <div class="table-scroll" role="region" aria-label="Your self-assessment history" tabindex="0"><asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" Caption="Your self-assessment history" UseAccessibleHeader="true" EmptyDataText="No earlier self-assessments yet."><Columns><asp:BoundField DataField="DateDisplay" HeaderText="Submitted (UTC)" HtmlEncode="true" /><asp:BoundField DataField="AverageDisplay" HeaderText="Average confidence out of 5" /><asp:BoundField DataField="Level" HeaderText="Feedback level" HtmlEncode="true" /><asp:HyperLinkField Text="Review ratings" DataNavigateUrlFields="ReviewUrl" HeaderText="Review" /></Columns></asp:GridView></div>
</asp:Panel>
<div class="actions"><asp:HyperLink ID="lnkBack" runat="server" Text="Back to the course" /><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="All my results" Visible="false" /></div>
</asp:Content>
