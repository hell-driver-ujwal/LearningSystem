<%@ Page Title="Activity oversight" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Activities.aspx.cs" Inherits="LearningSystem.Admin.Activities" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>All activities</h1><p class="intro">Every quiz, game, scenario, self-assessment and discussion. Activities with attempts cannot be deleted; unpublish them instead.</p></div></div>
<section class="filter-bar" aria-label="Filter activities">
<asp:Label ID="lblType" runat="server" AssociatedControlID="ddlType" Text="Activity type" />
<asp:DropDownList ID="ddlType" runat="server"><asp:ListItem Value="">All types</asp:ListItem><asp:ListItem>Quiz</asp:ListItem><asp:ListItem>SelfAssessment</asp:ListItem><asp:ListItem>Discussion</asp:ListItem><asp:ListItem>Game</asp:ListItem><asp:ListItem>Scenario</asp:ListItem></asp:DropDownList>
<asp:Button ID="btnFilter" runat="server" Text="Apply filter" OnClick="btnFilter_Click" ValidationGroup="Action" />
<asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="btnCancel_Click" CssClass="secondary" /></section>
<div class="table-scroll" role="region" aria-label="Activities" tabindex="0"><asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="false" DataKeyNames="ActivityID" Caption="Activities" UseAccessibleHeader="true" EmptyDataText="No activities found." OnRowCommand="Content_RowCommand" AllowPaging="true" PageSize="10" OnPageIndexChanging="Activities_PageIndexChanging">
<Columns>
<asp:BoundField DataField="Title" HeaderText="Title" HtmlEncode="true" />
<asp:BoundField DataField="ActivityType" HeaderText="Type" /><asp:BoundField DataField="CourseTitle" HeaderText="Course" HtmlEncode="true" />
<asp:BoundField DataField="Status" HeaderText="Status" />
<asp:BoundField DataField="AttemptCount" HeaderText="Attempts" />
<asp:TemplateField HeaderText="Actions"><ItemTemplate>
<asp:Button ID="btnUnpublish" runat="server" Text="Unpublish" CommandName="Unpublish" CommandArgument='<%# Eval("ActivityID") %>' ValidationGroup="Action" Enabled='<%# (string)Eval("Status") == "Published" %>' />
<asp:Button ID="btnDeleteContent" runat="server" Text="Delete" CommandName="DeleteContent" CommandArgument='<%# Eval("ActivityID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this content and its dependent records? Content with attempts cannot be deleted.');" />
<asp:HyperLink ID="lnkDiscussion" runat="server" Text="Discussion" NavigateUrl='<%# "~/Member/Discussion.aspx?id=" + Eval("ActivityID") %>' Visible='<%# (string)Eval("ActivityType") == "Discussion" %>' />
<asp:HyperLink ID="lnkPreviewActivity" runat="server" Text="Preview" Visible='<%# (string)Eval("ActivityType") == "Quiz" || (string)Eval("ActivityType") == "Discussion" || (string)Eval("ActivityType") == "SelfAssessment" || (string)Eval("ActivityType") == "Game" || (string)Eval("ActivityType") == "Scenario" %>' NavigateUrl='<%# "~/Member/" + ((string)Eval("ActivityType") == "Quiz" ? "Quiz" : (string)Eval("ActivityType") == "SelfAssessment" ? "SelfAssessment" : (string)Eval("ActivityType") == "Game" ? "PlayGame" : (string)Eval("ActivityType") == "Scenario" ? "Scenario" : "Discussion") + ".aspx?id=" + Eval("ActivityID") + "&preview=1" %>' />
</ItemTemplate></asp:TemplateField>
</Columns>
</asp:GridView></div>
</asp:Content>







