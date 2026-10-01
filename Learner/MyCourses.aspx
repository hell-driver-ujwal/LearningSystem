<%@ Page Title="My courses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="LearningSystem.Learner.MyCourses" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>My courses</h1><p><a href="../Courses.aspx">Find another course</a></p>
<div class="table-scroll" role="region" aria-label="Enrolled courses" tabindex="0"><asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="false" Caption="Enrolled courses" UseAccessibleHeader="true" EmptyDataText="You have not enrolled in any courses yet." OnRowCommand="CourseCommand"><Columns>
<asp:TemplateField HeaderText="Course"><ItemTemplate><asp:HyperLink ID="lnkCourse" runat="server" Text='<%#: Eval("Title") %>' NavigateUrl='<%# "CourseHome.aspx?id="+Eval("CourseID") %>' Visible='<%# (string)Eval("Status")=="Published" %>' /><asp:Literal ID="litUnavailable" runat="server" Mode="Encode" Text='<%# Eval("Title")+" — Currently unavailable" %>' Visible='<%# (string)Eval("Status")!="Published" %>' /></ItemTemplate></asp:TemplateField>
<asp:TemplateField HeaderText="Progress"><ItemTemplate><asp:Literal ID="litProgress" runat="server" Text='<%# ProgressFor(Eval("CourseID")) %>' /></ItemTemplate></asp:TemplateField>
<asp:TemplateField HeaderText="Actions"><ItemTemplate><asp:HyperLink ID="lnkCertificate" runat="server" Text="Certificate" NavigateUrl='<%# "Certificate.aspx?id="+Eval("CourseID") %>' Visible='<%# (string)Eval("Status")=="Published" && CanPrint(Eval("CourseID")) %>' /><asp:Button ID="btnLeave" runat="server" Text="Leave course" CommandName="LeaveCourse" CommandArgument='<%# Eval("CourseID") %>' ValidationGroup="Leave" OnClientClick="return confirm('Leave this course? Your learning records are retained if you enrol again.');" /></ItemTemplate></asp:TemplateField>
</Columns></asp:GridView></div>
</asp:Content>

