<%@ Page Title="Self-assessment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SelfAssessment.aspx.cs" Inherits="LearningSystem.Member.SelfAssessment" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false">Preview — no attempts or ratings are saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></asp:Panel>
<p class="preserve-lines"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
<asp:Panel ID="pnlResult" runat="server" Visible="false"><h2>Your confidence feedback</h2><p><asp:Literal ID="litResultContext" runat="server" Mode="Encode" /></p><p>Average confidence: <strong><asp:Literal ID="litAverage" runat="server" Mode="Encode" /></strong> — <asp:Literal ID="litLevel" runat="server" Mode="Encode" /></p><p><asp:Literal ID="litFeedback" runat="server" Mode="Encode" /></p>
<div class="table-scroll" role="region" aria-label="Your saved statement ratings" tabindex="0"><asp:GridView ID="gvResponses" runat="server" AutoGenerateColumns="false" Caption="Your saved statement ratings" EmptyDataText="No saved ratings to display in this preview." UseAccessibleHeader="true"><Columns><asp:BoundField DataField="StatementText" HeaderText="Statement" HtmlEncode="true" /><asp:BoundField DataField="Rating" HeaderText="Rating / 5" /></Columns></asp:GridView></div></asp:Panel>
<section class="form-card"><h2>Rate your confidence</h2><p>Rate every statement from 1 (lowest confidence) to 5 (highest confidence). These are confidence ratings, not test scores. You can submit a new assessment whenever you wish.</p>
<asp:ValidationSummary ID="vsRatings" runat="server" ValidationGroup="Ratings" />
<asp:CustomValidator ID="cvRatings" runat="server" ValidationGroup="Ratings" OnServerValidate="ValidateRatings" ErrorMessage="Rate every statement with an integer from 1 through 5." />
<asp:Label ID="lblEmpty" runat="server" Text="No statements are available yet." />
<asp:Repeater ID="rptStatements" runat="server"><ItemTemplate><div class="field">
<asp:HiddenField ID="hfStatement" runat="server" Value='<%# Eval("StatementID") %>' />
<asp:Label ID="lblRating" runat="server" AssociatedControlID="ddlRating" Text='<%# System.Web.HttpUtility.HtmlEncode(Convert.ToString(Eval("StatementText"))) %>' />
<asp:DropDownList ID="ddlRating" runat="server"><asp:ListItem Value="">Choose a rating</asp:ListItem><asp:ListItem Value="1">1</asp:ListItem><asp:ListItem Value="2">2</asp:ListItem><asp:ListItem Value="3">3</asp:ListItem><asp:ListItem Value="4">4</asp:ListItem><asp:ListItem Value="5">5</asp:ListItem></asp:DropDownList>
<asp:RequiredFieldValidator ID="rfvRating" runat="server" ControlToValidate="ddlRating" ValidationGroup="Ratings" ErrorMessage="Every statement requires a rating." />
<asp:RangeValidator ID="rvRating" runat="server" ControlToValidate="ddlRating" ValidationGroup="Ratings" Type="Integer" MinimumValue="1" MaximumValue="5" ErrorMessage="Ratings must be integers from 1 through 5." />
</div></ItemTemplate></asp:Repeater>
<div class="actions"><asp:Button ID="btnSubmit" runat="server" Text="Submit self-assessment" ValidationGroup="Ratings" OnClick="SubmitAssessment" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /></div></section>
<asp:Panel ID="pnlHistory" runat="server"><h2>Past self-assessments</h2><p>Compare your confidence over time. Each row is one submitted assessment.</p>
<div class="table-scroll" role="region" aria-label="Your self-assessment history" tabindex="0"><asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" Caption="Your self-assessment history" UseAccessibleHeader="true" EmptyDataText="No past self-assessments yet."><Columns><asp:BoundField DataField="DateDisplay" HeaderText="Submitted (UTC)" HtmlEncode="true" /><asp:BoundField DataField="AverageDisplay" HeaderText="Average confidence / 5" /><asp:BoundField DataField="Level" HeaderText="Feedback level" HtmlEncode="true" /><asp:HyperLinkField Text="Review ratings" DataNavigateUrlFields="ReviewUrl" HeaderText="Review" /></Columns></asp:GridView></div></asp:Panel>
<p><asp:HyperLink ID="lnkBack" runat="server" Text="Back to course / activities" /></p>
<p><asp:HyperLink ID="lnkMyResults" runat="server" NavigateUrl="~/Learner/MyResults.aspx" Text="My results" Visible="false" /></p>
</asp:Content>



