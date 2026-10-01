<%@ Page Title="Course oversight" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="LearningSystem.Admin.Courses" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Course oversight</h1>
<p>All courses from every teacher. Content with submitted attempts cannot be deleted. Use Unpublish to hide it while keeping results.</p>

<div class="table-scroll" role="region" aria-label="Courses" tabindex="0"><asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="false" DataKeyNames="CourseID" Caption="Courses" UseAccessibleHeader="true" EmptyDataText="No courses found." OnRowCommand="Content_RowCommand" >
<Columns>
<asp:BoundField DataField="Title" HeaderText="Title" HtmlEncode="true" />
<asp:BoundField DataField="SubjectName" HeaderText="Subject" HtmlEncode="true" /><asp:BoundField DataField="TeacherName" HeaderText="Teacher" HtmlEncode="true" />
<asp:BoundField DataField="Status" HeaderText="Status" />
<asp:BoundField DataField="AttemptCount" HeaderText="Attempts" />
<asp:TemplateField HeaderText="Material previews"><ItemTemplate><details><summary>Preview materials</summary><%# PreviewLinks(Eval("CourseID")) %></details></ItemTemplate></asp:TemplateField>
<asp:TemplateField HeaderText="Actions"><ItemTemplate>
<asp:Button ID="btnUnpublish" runat="server" Text="Unpublish" CommandName="Unpublish" CommandArgument='<%# Eval("CourseID") %>' ValidationGroup="Action" Enabled='<%# (string)Eval("Status") == "Published" %>' />
<asp:Button ID="btnDeleteContent" runat="server" Text="Delete" CommandName="DeleteContent" CommandArgument='<%# Eval("CourseID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this content and its dependent records? Content with attempts cannot be deleted.');" />
</ItemTemplate></asp:TemplateField>
</Columns>
</asp:GridView></div>
<h2>Review moderation</h2><div class="table-scroll" role="region" aria-label="Course reviews" tabindex="0"><asp:GridView ID="gvReviews" runat="server" Caption="Reviews for all courses" UseAccessibleHeader="true" AutoGenerateColumns="false" EmptyDataText="No reviews yet." OnRowCommand="ReviewCommand"><Columns><asp:BoundField DataField="CourseTitle" HeaderText="Course" HtmlEncode="true" /><asp:BoundField DataField="FullName" HeaderText="Learner" HtmlEncode="true" /><asp:BoundField DataField="Rating" HeaderText="Rating / 5" /><asp:BoundField DataField="Comment" HeaderText="Comment" HtmlEncode="true" /><asp:TemplateField HeaderText="Action"><ItemTemplate><asp:Button ID="btnRemoveReview" runat="server" Text="Remove review" CommandName="RemoveReview" CommandArgument='<%# Eval("ReviewID") %>' ValidationGroup="Review" OnClientClick="return confirm('Remove this review?');" /></ItemTemplate></asp:TemplateField></Columns></asp:GridView></div>
</asp:Content>



