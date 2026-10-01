<%@ Page Title="Course catalogue" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="LearningSystem.Courses" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Course catalogue</h1>
<section class="form-card filter-card" aria-label="Find courses"><asp:ValidationSummary ID="vsSearch" runat="server" ValidationGroup="Search" />
<div class="field"><asp:Label ID="lblSearch" runat="server" AssociatedControlID="txtSearch" Text="Search titles and descriptions" /><asp:TextBox ID="txtSearch" runat="server" TextMode="Search" MaxLength="50" /><asp:RegularExpressionValidator ID="revSearch" runat="server" ControlToValidate="txtSearch" ValidationGroup="Search" ValidationExpression="^[\s\S]{0,50}$" ErrorMessage="Search must be at most 50 characters." /></div>
<div class="field"><asp:Label ID="lblSubject" runat="server" AssociatedControlID="ddlSubject" Text="Subject" /><asp:DropDownList ID="ddlSubject" runat="server" /></div>
<div class="actions"><asp:Button ID="btnSearch" runat="server" Text="Search courses" ValidationGroup="Search" OnClick="SearchCourses" /><asp:Button ID="btnCancel" runat="server" Text="Cancel / clear filters" CausesValidation="false" OnClick="ClearFilters" CssClass="secondary" /></div></section>
<h2>Explore courses</h2><asp:PlaceHolder ID="phCourses" runat="server" />
<div class="actions" aria-label="Catalogue pages"><asp:Button ID="btnPrevious" runat="server" Text="Previous page" CausesValidation="false" OnClick="PreviousCoursesPage" /><asp:Label ID="lblPage" runat="server" /><asp:Button ID="btnNext" runat="server" Text="Next page" CausesValidation="false" OnClick="NextPage" /></div>
</asp:Content>


