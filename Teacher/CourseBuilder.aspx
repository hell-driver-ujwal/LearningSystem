<%@ Page Title="Course builder" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseBuilder.aspx.cs" Inherits="LearningSystem.Teacher.CourseBuilder" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Course builder</h1>
<p><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></p>
<p><asp:HyperLink ID="lnkLearners" runat="server" Text="Enrolled learners" /> · <asp:HyperLink ID="lnkResults" runat="server" Text="Course results" /> · <asp:HyperLink ID="lnkDetails" runat="server" Text="Edit course details" /> · <a href="MyCourses.aspx">My courses and publication</a></p>
<section class="form-card" aria-label="Topic editor">
<h2>Add or edit a topic</h2>
<asp:ValidationSummary ID="vsForm" runat="server" ValidationGroup="Topic" CssClass="validation-summary" />
<div class="field"><asp:Label ID="lblTitle" runat="server" AssociatedControlID="txtTitle" Text="Topic title" /><asp:TextBox ID="txtTitle" runat="server" MaxLength="100" />
<asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Topic" ErrorMessage="Enter a topic title." />
<asp:RegularExpressionValidator ID="revTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Topic" ValidationExpression="^[\s\S]{3,100}$" ErrorMessage="Topic title must be 3–100 characters." /></div>
<div class="field"><asp:Label ID="lblOrder" runat="server" AssociatedControlID="txtOrder" Text="Order (1–100; ties allowed)" /><asp:TextBox ID="txtOrder" runat="server" TextMode="Number" />
<asp:RequiredFieldValidator ID="rfvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Topic" ErrorMessage="Enter an order." />
<asp:RangeValidator ID="rvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Topic" Type="Integer" MinimumValue="1" MaximumValue="100" ErrorMessage="Topic order must be 1–100. If the next position exceeds 100, choose an existing position; ties are allowed." /></div>
<div class="actions"><asp:Button ID="btnSave" runat="server" Text="Add topic" ValidationGroup="Topic" OnClick="SaveTopic" />
<asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" CssClass="secondary" /></div>
</section>
<h2>Course topics</h2>
<asp:Label ID="lblEmpty" runat="server" Text="No topics yet. Add your first topic above." Visible="false" />
<asp:Repeater ID="rptTopics" runat="server" OnItemDataBound="BindTopic" OnItemCommand="TopicCommand"><ItemTemplate>
<article class="topic-card">
<h3><%#: Eval("Title") %></h3><p>Order: <%#: Eval("SortOrder") %></p>
<div class="actions">
<asp:Button ID="btnEditTopic" runat="server" Text="Edit topic / order" CommandName="EditTopic" CommandArgument='<%# Eval("TopicID") %>' ValidationGroup="Action" />
<asp:Button ID="btnDeleteTopic" runat="server" Text="Delete topic" CommandName="DeleteTopic" CommandArgument='<%# Eval("TopicID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this topic and its content? Topics with attempts cannot be deleted.');" />
<asp:HyperLink ID="lnkAddScenario" runat="server" Text="Add Scenario" NavigateUrl='<%# "ScenarioBuilder.aspx?topicId=" + Eval("TopicID") %>' />
<asp:HyperLink ID="lnkAddGame" runat="server" Text="Add Game" NavigateUrl='<%# "GameBuilder.aspx?topicId=" + Eval("TopicID") %>' />
<asp:HyperLink ID="lnkAddSelfAssessment" runat="server" Text="Add Self-Assessment" NavigateUrl='<%# "SABuilder.aspx?topicId=" + Eval("TopicID") %>' />
<asp:HyperLink ID="lnkAddQuiz" runat="server" Text="Add Quiz" NavigateUrl='<%# "QuizBuilder.aspx?topicId=" + Eval("TopicID") %>' />
<asp:HyperLink ID="lnkAddDiscussion" runat="server" Text="Add Discussion" NavigateUrl='<%# "DiscussionEdit.aspx?topicId=" + Eval("TopicID") %>' />
<asp:HyperLink ID="lnkAddMaterial" runat="server" Text="Add material" NavigateUrl='<%# "MaterialEdit.aspx?topicId=" + Eval("TopicID") %>' />
</div>
<div class="table-scroll" role="region" aria-label="Materials" tabindex="0"><asp:GridView ID="gvMaterials" runat="server" AutoGenerateColumns="false" Caption="Materials" UseAccessibleHeader="true" EmptyDataText="No materials in this topic." OnRowCommand="MaterialCommand"><Columns>
<asp:BoundField DataField="Title" HeaderText="Title" HtmlEncode="true" />
<asp:BoundField DataField="MaterialType" HeaderText="Type" /><asp:BoundField DataField="Status" HeaderText="Status" /><asp:BoundField DataField="SortOrder" HeaderText="Order" />
<asp:CheckBoxField DataField="IsPreview" HeaderText="Free preview" />
<asp:TemplateField HeaderText="Actions"><ItemTemplate>
<asp:HyperLink ID="lnkEditMaterial" runat="server" Text="Edit / publish" NavigateUrl='<%# "MaterialEdit.aspx?id=" + Eval("MaterialID") %>' />
<asp:HyperLink ID="lnkPreviewMaterial" runat="server" Text="Preview" NavigateUrl='<%# "~/Member/Lesson.aspx?id=" + Eval("MaterialID") + "&preview=1" %>' />
<asp:Button ID="btnDeleteMaterial" runat="server" Text="Delete" CommandName="DeleteMaterial" CommandArgument='<%# Eval("MaterialID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this material and its unreferenced file?');" />
</ItemTemplate></asp:TemplateField>
</Columns></asp:GridView></div>
<div class="table-scroll" role="region" aria-label="Activities" tabindex="0"><asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="false" Caption="Activities" UseAccessibleHeader="true" EmptyDataText="No activities in this topic."><Columns>
<asp:BoundField DataField="Title" HeaderText="Title" HtmlEncode="true" /><asp:BoundField DataField="ActivityType" HeaderText="Type" /><asp:BoundField DataField="Status" HeaderText="Status" /><asp:BoundField DataField="SortOrder" HeaderText="Order" />
<asp:TemplateField HeaderText="Actions"><ItemTemplate>
<asp:HyperLink ID="lnkEditActivity" runat="server" Text="Edit / publish" Visible='<%# (string)Eval("ActivityType") == "Quiz" || (string)Eval("ActivityType") == "Discussion" || (string)Eval("ActivityType") == "SelfAssessment" || (string)Eval("ActivityType") == "Game" || (string)Eval("ActivityType") == "Scenario" %>' NavigateUrl='<%# ((string)Eval("ActivityType") == "Quiz" ? "QuizBuilder" : (string)Eval("ActivityType") == "SelfAssessment" ? "SABuilder" : (string)Eval("ActivityType") == "Game" ? "GameBuilder" : (string)Eval("ActivityType") == "Scenario" ? "ScenarioBuilder" : "DiscussionEdit") + ".aspx?id=" + Eval("ActivityID") %>' />
<asp:HyperLink ID="lnkPreviewActivity" runat="server" Text="Preview" Visible='<%# (string)Eval("ActivityType") == "Quiz" || (string)Eval("ActivityType") == "Discussion" || (string)Eval("ActivityType") == "SelfAssessment" || (string)Eval("ActivityType") == "Game" || (string)Eval("ActivityType") == "Scenario" %>' NavigateUrl='<%# "~/Member/" + ((string)Eval("ActivityType") == "Quiz" ? "Quiz" : (string)Eval("ActivityType") == "SelfAssessment" ? "SelfAssessment" : (string)Eval("ActivityType") == "Game" ? "PlayGame" : (string)Eval("ActivityType") == "Scenario" ? "Scenario" : "Discussion") + ".aspx?id=" + Eval("ActivityID") + "&preview=1" %>' />
<asp:HyperLink ID="lnkModerateDiscussion" runat="server" Text="Open / moderate discussion" Visible='<%# (string)Eval("ActivityType") == "Discussion" && (string)Eval("Status") == "Published" %>' NavigateUrl='<%# "~/Member/Discussion.aspx?id=" + Eval("ActivityID") %>' />
</ItemTemplate></asp:TemplateField>
</Columns></asp:GridView></div>
</article>
</ItemTemplate></asp:Repeater>
</asp:Content>






