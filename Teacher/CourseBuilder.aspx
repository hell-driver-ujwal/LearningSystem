<%@ Page Title="Course builder" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseBuilder.aspx.cs" Inherits="LearningSystem.Teacher.CourseBuilder" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header">
    <div><p class="eyebrow">Course builder</p><h1><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></h1><p class="intro">Organise the course into topics, then add lessons and activities to each one. Learners see only published items.</p></div>
    <div class="actions" style="margin:0"><asp:HyperLink ID="lnkDetails" runat="server" Text="Edit course details" CssClass="button secondary" /><a class="button secondary" href="MyCourses.aspx">Publish settings</a></div>
</div>
<p class="muted"><asp:HyperLink ID="lnkLearners" runat="server" Text="Enrolled learners" /> &middot; <asp:HyperLink ID="lnkResults" runat="server" Text="Course results" /></p>
<section class="form-card wide" aria-labelledby="topic-form-title">
    <h2 id="topic-form-title">Add or edit a topic</h2>
    <asp:ValidationSummary ID="vsForm" runat="server" ValidationGroup="Topic" CssClass="validation-summary" />
    <div class="form-grid">
        <div class="field"><asp:Label ID="lblTitle" runat="server" AssociatedControlID="txtTitle" Text="Topic title" /><asp:TextBox ID="txtTitle" runat="server" MaxLength="100" placeholder="For example: Styling with CSS" />
        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Topic" ErrorMessage="Enter a topic title." Display="Dynamic" />
        <asp:RegularExpressionValidator ID="revTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Topic" ValidationExpression="^[\s\S]{3,100}$" ErrorMessage="Topic title must be 3 to 100 characters." Display="Dynamic" /></div>
        <div class="field"><asp:Label ID="lblOrder" runat="server" AssociatedControlID="txtOrder" Text="Position in the course (1 to 100)" /><asp:TextBox ID="txtOrder" runat="server" TextMode="Number" />
        <asp:RequiredFieldValidator ID="rfvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Topic" ErrorMessage="Enter a position." Display="Dynamic" />
        <asp:RangeValidator ID="rvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Topic" Type="Integer" MinimumValue="1" MaximumValue="100" ErrorMessage="Position must be a whole number from 1 to 100." Display="Dynamic" /></div>
    </div>
    <div class="actions"><asp:Button ID="btnSave" runat="server" Text="Add topic" ValidationGroup="Topic" OnClick="SaveTopic" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" CssClass="secondary" /></div>
</section>
<h2>Topics</h2>
<asp:Label ID="lblEmpty" runat="server" Text="No topics yet. Add your first topic above, then add lessons and activities to it." Visible="false" CssClass="empty-state" />
<asp:Repeater ID="rptTopics" runat="server" OnItemDataBound="BindTopic" OnItemCommand="TopicCommand"><ItemTemplate>
<article class="topic-card builder-topic">
    <h3 class="topic-head"><span><%#: Eval("SortOrder") %>. <%#: Eval("Title") %></span>
        <span class="actions" style="margin:0"><asp:Button ID="btnEditTopic" runat="server" Text="Edit topic" CssClass="small" CommandName="EditTopic" CommandArgument='<%# Eval("TopicID") %>' ValidationGroup="Action" />
        <asp:Button ID="btnDeleteTopic" runat="server" Text="Delete topic" CssClass="small" CommandName="DeleteTopic" CommandArgument='<%# Eval("TopicID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this topic and everything in it? Topics with learner attempts cannot be deleted.');" /></span></h3>
    <nav class="add-menu" aria-label='<%#: "Add to " + Eval("Title") %>'>
        <a href='<%# "MaterialEdit.aspx?topicId=" + Eval("TopicID") %>'><%# LearningSystem.Helpers.UiHelper.Icon("book") %> Lesson</a>
        <a href='<%# "QuizBuilder.aspx?topicId=" + Eval("TopicID") %>'><%# LearningSystem.Helpers.UiHelper.Icon("quiz") %> Quiz</a>
        <a href='<%# "GameBuilder.aspx?topicId=" + Eval("TopicID") %>'><%# LearningSystem.Helpers.UiHelper.Icon("puzzle") %> Game</a>
        <a href='<%# "ScenarioBuilder.aspx?topicId=" + Eval("TopicID") %>'><%# LearningSystem.Helpers.UiHelper.Icon("route") %> Scenario</a>
        <a href='<%# "SABuilder.aspx?topicId=" + Eval("TopicID") %>'><%# LearningSystem.Helpers.UiHelper.Icon("gauge") %> Self-assessment</a>
        <a href='<%# "DiscussionEdit.aspx?topicId=" + Eval("TopicID") %>'><%# LearningSystem.Helpers.UiHelper.Icon("chat") %> Discussion</a>
    </nav>
    <div class="table-scroll" role="region" aria-label="Lessons in this topic" tabindex="0"><asp:GridView ID="gvMaterials" runat="server" AutoGenerateColumns="false" Caption="Lessons" UseAccessibleHeader="true" EmptyDataText="No lessons in this topic yet." OnRowCommand="MaterialCommand"><Columns>
        <asp:BoundField DataField="Title" HeaderText="Title" HtmlEncode="true" />
        <asp:BoundField DataField="MaterialType" HeaderText="Type" /><asp:BoundField DataField="Status" HeaderText="Status" /><asp:BoundField DataField="SortOrder" HeaderText="Order" />
        <asp:CheckBoxField DataField="IsPreview" HeaderText="Free preview" />
        <asp:TemplateField HeaderText="Actions"><ItemTemplate>
            <asp:HyperLink ID="lnkEditMaterial" runat="server" Text="Edit" NavigateUrl='<%# "MaterialEdit.aspx?id=" + Eval("MaterialID") %>' />
            <asp:HyperLink ID="lnkPreviewMaterial" runat="server" Text="Preview" NavigateUrl='<%# "~/Member/Lesson.aspx?id=" + Eval("MaterialID") + "&preview=1" %>' />
            <asp:Button ID="btnDeleteMaterial" runat="server" Text="Delete" CommandName="DeleteMaterial" CommandArgument='<%# Eval("MaterialID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this lesson and its uploaded file?');" />
        </ItemTemplate></asp:TemplateField>
    </Columns></asp:GridView></div>
    <div class="table-scroll" role="region" aria-label="Activities in this topic" tabindex="0"><asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="false" Caption="Activities" UseAccessibleHeader="true" EmptyDataText="No activities in this topic yet."><Columns>
        <asp:BoundField DataField="Title" HeaderText="Title" HtmlEncode="true" /><asp:BoundField DataField="ActivityType" HeaderText="Type" /><asp:BoundField DataField="Status" HeaderText="Status" /><asp:BoundField DataField="SortOrder" HeaderText="Order" />
        <asp:TemplateField HeaderText="Actions"><ItemTemplate>
            <asp:HyperLink ID="lnkEditActivity" runat="server" Text="Edit" Visible='<%# (string)Eval("ActivityType") == "Quiz" || (string)Eval("ActivityType") == "Discussion" || (string)Eval("ActivityType") == "SelfAssessment" || (string)Eval("ActivityType") == "Game" || (string)Eval("ActivityType") == "Scenario" %>' NavigateUrl='<%# ((string)Eval("ActivityType") == "Quiz" ? "QuizBuilder" : (string)Eval("ActivityType") == "SelfAssessment" ? "SABuilder" : (string)Eval("ActivityType") == "Game" ? "GameBuilder" : (string)Eval("ActivityType") == "Scenario" ? "ScenarioBuilder" : "DiscussionEdit") + ".aspx?id=" + Eval("ActivityID") %>' />
            <asp:HyperLink ID="lnkPreviewActivity" runat="server" Text="Preview" Visible='<%# (string)Eval("ActivityType") == "Quiz" || (string)Eval("ActivityType") == "Discussion" || (string)Eval("ActivityType") == "SelfAssessment" || (string)Eval("ActivityType") == "Game" || (string)Eval("ActivityType") == "Scenario" %>' NavigateUrl='<%# "~/Member/" + ((string)Eval("ActivityType") == "Quiz" ? "Quiz" : (string)Eval("ActivityType") == "SelfAssessment" ? "SelfAssessment" : (string)Eval("ActivityType") == "Game" ? "PlayGame" : (string)Eval("ActivityType") == "Scenario" ? "Scenario" : "Discussion") + ".aspx?id=" + Eval("ActivityID") + "&preview=1" %>' />
            <asp:HyperLink ID="lnkModerateDiscussion" runat="server" Text="Moderate" Visible='<%# (string)Eval("ActivityType") == "Discussion" && (string)Eval("Status") == "Published" %>' NavigateUrl='<%# "~/Member/Discussion.aspx?id=" + Eval("ActivityID") %>' />
        </ItemTemplate></asp:TemplateField>
    </Columns></asp:GridView></div>
</article>
</ItemTemplate></asp:Repeater>
</asp:Content>
