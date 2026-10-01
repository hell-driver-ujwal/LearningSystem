<%@ Page Title="Course catalogue" MetaDescription="Browse every Inkwell course. Search by keyword, filter by subject or price, and open the free preview lessons before you enrol." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="LearningSystem.Courses" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header">
    <div><h1>Course catalogue</h1><p class="intro">Every course includes free preview lessons you can open before you enrol.</p></div>
</div>
<section class="form-card filter-card" aria-label="Find courses">
    <asp:ValidationSummary ID="vsSearch" runat="server" ValidationGroup="Search" />
    <div class="field"><asp:Label ID="lblSearch" runat="server" AssociatedControlID="txtSearch" Text="Search titles and descriptions" /><asp:TextBox ID="txtSearch" runat="server" TextMode="Search" MaxLength="50" placeholder="For example: python, budget, cells" /><asp:RegularExpressionValidator ID="revSearch" runat="server" ControlToValidate="txtSearch" ValidationGroup="Search" ValidationExpression="^[\s\S]{0,50}$" ErrorMessage="Search must be at most 50 characters." Display="Dynamic" /></div>
    <div class="field"><asp:Label ID="lblSubject" runat="server" AssociatedControlID="ddlSubject" Text="Subject" /><asp:DropDownList ID="ddlSubject" runat="server" /></div>
    <div class="field"><asp:Label ID="lblPrice" runat="server" AssociatedControlID="ddlPrice" Text="Price" /><asp:DropDownList ID="ddlPrice" runat="server"><asp:ListItem Value="">Free and paid</asp:ListItem><asp:ListItem Value="free">Free only</asp:ListItem><asp:ListItem Value="paid">Paid only</asp:ListItem></asp:DropDownList></div>
    <div class="field"><asp:Label ID="lblSort" runat="server" AssociatedControlID="ddlSort" Text="Sort by" /><asp:DropDownList ID="ddlSort" runat="server"><asp:ListItem Value="">Newest first</asp:ListItem><asp:ListItem Value="title">Title A to Z</asp:ListItem><asp:ListItem Value="popular">Most learners</asp:ListItem></asp:DropDownList></div>
    <div class="actions"><asp:Button ID="btnSearch" runat="server" Text="Show courses" ValidationGroup="Search" OnClick="SearchCourses" /><asp:Button ID="btnCancel" runat="server" Text="Clear filters" CausesValidation="false" OnClick="ClearFilters" CssClass="secondary" /></div>
</section>
<p class="muted" role="status"><asp:Literal ID="litCount" runat="server" Mode="Encode" /></p>
<h2 class="visually-hidden">Courses</h2>
<asp:PlaceHolder ID="phCourses" runat="server" />
<nav class="actions" aria-label="Catalogue pages">
    <asp:Button ID="btnPrevious" runat="server" Text="Previous page" CausesValidation="false" OnClick="PreviousCoursesPage" CssClass="secondary" />
    <asp:Label ID="lblPage" runat="server" CssClass="muted" />
    <asp:Button ID="btnNext" runat="server" Text="Next page" CausesValidation="false" OnClick="NextPage" CssClass="secondary" />
</nav>
</asp:Content>
