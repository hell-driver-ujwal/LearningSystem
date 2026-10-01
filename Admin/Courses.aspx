<%@ Page Title="Course oversight" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="LearningSystem.Admin.Courses" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>All courses</h1><p class="intro">Every course from every lecturer. Content with learner attempts cannot be deleted; unpublish it to hide it and keep the results.</p></div><a class="button secondary" href="../Teacher/MyCourses.aspx">My authored courses</a></div>

<div class="table-scroll" role="region" aria-label="Courses" tabindex="0"><asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="false" DataKeyNames="CourseID" Caption="Courses" UseAccessibleHeader="true" EmptyDataText="No courses found." OnRowCommand="Content_RowCommand" >
<Columns>
<asp:BoundField DataField="Title" HeaderText="Title" HtmlEncode="true" />
<asp:BoundField DataField="SubjectName" HeaderText="Subject" HtmlEncode="true" /><asp:BoundField DataField="TeacherName" HeaderText="Lecturer" HtmlEncode="true" />
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



