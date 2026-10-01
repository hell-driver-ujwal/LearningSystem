<%@ Page Title="My courses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="LearningSystem.Learner.MyCourses" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header">
    <div><h1>My courses</h1><p class="intro">Leaving a course keeps your results. If you enrol again, your progress comes back.</p></div>
    <a class="button secondary" href="../Courses.aspx">Find another course</a>
</div>
<asp:Label ID="lblEmpty" runat="server" Visible="false" CssClass="empty-state" Text="You have not enrolled in any courses yet. Browse the catalogue to find one." />
<asp:Repeater ID="rptCourses" runat="server" OnItemCommand="CourseCommand"><HeaderTemplate><div class="course-grid"></HeaderTemplate><ItemTemplate>
    <article class="course-card" style="cursor:default">
        <%# CourseCover(Container.DataItem) %>
        <div class="course-body">
            <p class="course-subject"><%#: Eval("SubjectName") %></p>
            <h3><%# CourseTitle(Container.DataItem) %></h3>
            <%# ProgressFor(Eval("CourseID"), Eval("Status")) %>
            <div class="actions" style="margin-top:12px;position:relative;z-index:1">
                <asp:HyperLink ID="lnkCertificate" runat="server" Text="Certificate" CssClass="button small accent" NavigateUrl='<%# "Certificate.aspx?id="+Eval("CourseID") %>' Visible='<%# (string)Eval("Status")=="Published" && CanPrint(Eval("CourseID")) %>' />
                <asp:Button ID="btnLeave" runat="server" Text="Leave course" CssClass="small" CommandName="LeaveCourse" CommandArgument='<%# Eval("CourseID") %>' ValidationGroup="Leave" OnClientClick="return confirm('Leave this course? Your learning records are kept if you enrol again.');" />
            </div>
        </div>
    </article>
</ItemTemplate><FooterTemplate></div></FooterTemplate></asp:Repeater>
</asp:Content>
