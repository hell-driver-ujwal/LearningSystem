<%@ Page Title="My courses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="LearningSystem.Teacher.MyCourses" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>My courses</h1>
<p><a href="CourseEdit.aspx">Create course</a></p>
<div class="table-scroll" role="region" aria-label="Your courses" tabindex="0"><asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="false" Caption="Your courses" UseAccessibleHeader="true" EmptyDataText="No courses yet. Create your first course." OnRowCommand="CourseCommand">
<Columns>
<asp:BoundField DataField="Title" HeaderText="Course" HtmlEncode="true" />
<asp:BoundField DataField="SubjectName" HeaderText="Subject" HtmlEncode="true" />
<asp:BoundField DataField="Status" HeaderText="Status" />
<asp:TemplateField HeaderText="Actions"><ItemTemplate>
<asp:HyperLink ID="lnkLearners" runat="server" Text="Enrolled learners" NavigateUrl='<%# "CourseLearners.aspx?id=" + Eval("CourseID") %>' />
<asp:HyperLink ID="lnkResults" runat="server" Text="Results" NavigateUrl='<%# "Results.aspx?courseId=" + Eval("CourseID") %>' />
<asp:HyperLink ID="lnkBuild" runat="server" Text="Build" NavigateUrl='<%# "CourseBuilder.aspx?id=" + Eval("CourseID") %>' />
<asp:HyperLink ID="lnkEdit" runat="server" Text="Edit details" NavigateUrl='<%# "CourseEdit.aspx?id=" + Eval("CourseID") %>' />
<asp:Button ID="btnPublish" runat="server" Text="Publish" CommandName="PublishCourse" CommandArgument='<%# Eval("CourseID") %>' ValidationGroup="Action" Visible='<%# (string)Eval("Status") == "Draft" %>' />
<asp:Button ID="btnUnpublish" runat="server" Text="Unpublish" CommandName="UnpublishCourse" CommandArgument='<%# Eval("CourseID") %>' ValidationGroup="Action" Visible='<%# (string)Eval("Status") == "Published" %>' />
<asp:Button ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteCourse" CommandArgument='<%# Eval("CourseID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this course and its content? Courses with attempts cannot be deleted.');" />
</ItemTemplate></asp:TemplateField>
</Columns>
</asp:GridView></div>
</asp:Content>


