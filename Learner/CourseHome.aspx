<%@ Page Title="Course home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseHome.aspx.cs" Inherits="LearningSystem.Learner.CourseHome" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header">
    <div><p class="chip"><asp:Literal ID="litSubject" runat="server" Mode="Encode" /></p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1><p class="muted"><asp:Literal ID="litTeacher" runat="server" Mode="Encode" /></p></div>
    <asp:HyperLink ID="lnkDetails" runat="server" CssClass="button secondary" Text="Course page and reviews" />
</div>
<div class="path-wrap">
    <section aria-labelledby="path-title">
        <h2 id="path-title" class="visually-hidden">Course path</h2>
        <%-- Every lesson and activity in course order; any node can be opened, the glowing one is next --%>
        <asp:PlaceHolder ID="phOutline" runat="server" />
    </section>
    <aside class="path-side" aria-label="Course progress">
        <section class="card" aria-labelledby="progress-title">
            <h2 id="progress-title" style="margin-top:0;font-size:1.15rem">Your progress</h2>
            <asp:Literal ID="litProgress" runat="server" />
            <div class="actions" style="flex-direction:column;align-items:stretch">
                <asp:HyperLink ID="lnkNext" runat="server" CssClass="button accent" />
                <asp:HyperLink ID="lnkCertificate" runat="server" Text="Print certificate" Visible="false" CssClass="button" />
            </div>
        </section>
        <section class="card" aria-labelledby="key-title">
            <h2 id="key-title" style="margin-top:0;font-size:1.05rem">Path key</h2>
            <ul class="includes">
                <li><span class="node-icon" style="--c:var(--green);--e:var(--green-edge);width:28px;height:26px;border-bottom-width:3px;color:var(--on-bright)"><%= LearningSystem.Helpers.UiHelper.Icon("check") %></span>Done</li>
                <li><span class="node-icon" style="--c:var(--role);--e:var(--role-edge);width:28px;height:26px;border-bottom-width:3px"></span>Up next</li>
                <li><span class="node-icon" style="width:28px;height:26px;border-bottom-width:3px"></span>Still to do (open any time)</li>
            </ul>
        </section>
        <p><a href="MyCourses.aspx"><%= LearningSystem.Helpers.UiHelper.Icon("arrow-left") %> Back to my courses</a></p>
    </aside>
</div>
</asp:Content>
