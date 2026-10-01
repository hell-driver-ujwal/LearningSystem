<%@ Page Title="Course details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseDetails.aspx.cs" Inherits="LearningSystem.CourseDetails" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="course-hero">
    <section aria-labelledby="course-title">
        <p class="chip"><asp:Literal ID="litSubject" runat="server" Mode="Encode" /></p>
        <h1 id="course-title"><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
        <p class="lede"><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p>
        <asp:Literal ID="litFacts" runat="server" />
        <p class="metadata muted"><asp:Literal ID="litMetadata" runat="server" Mode="Encode" /></p>
        <h2>What you will practise</h2>
        <asp:Literal ID="litPractice" runat="server" />
    </section>
    <aside class="enrol-card" aria-label="Enrolment">
        <asp:Image ID="imgCover" runat="server" CssClass="course-cover" Visible="false" />
        <div class="inner">
            <p class="course-price"><asp:Literal ID="litPrice" runat="server" Mode="Encode" /></p>
            <div class="actions">
                <asp:Button ID="btnEnrol" runat="server" Text="Enrol for free" OnClick="Enrol" ValidationGroup="Enrol" Visible="false" CssClass="large" />
                <asp:HyperLink ID="lnkLogin" runat="server" Text="Log in to enrol" Visible="false" CssClass="button large" />
                <asp:HyperLink ID="lnkJoin" runat="server" Text="Create a free account" Visible="false" CssClass="button secondary" NavigateUrl="~/Account/Register.aspx" />
                <asp:HyperLink ID="lnkStudy" runat="server" Text="Continue learning" Visible="false" CssClass="button large" />
            </div>
            <p class="hint"><asp:Literal ID="litEnrolNote" runat="server" Mode="Encode" /></p>
            <asp:Literal ID="litIncludes" runat="server" />
        </div>
    </aside>
</div>

<section aria-labelledby="content-title">
    <div class="section-head"><div><h2 id="content-title">Course content</h2><p><asp:Literal ID="litContentSummary" runat="server" Mode="Encode" /></p></div></div>
    <asp:PlaceHolder ID="phOutline" runat="server" />
</section>

<section aria-labelledby="lecturer-title" class="section">
    <h2 id="lecturer-title">Your lecturer</h2>
    <asp:Literal ID="litLecturer" runat="server" />
</section>

<section id="reviews" aria-labelledby="reviews-title" class="section">
    <div class="section-head"><div><h2 id="reviews-title">Learner reviews</h2><p><asp:Literal ID="litRating" runat="server" Mode="Encode" /></p></div></div>
    <asp:Label ID="lblNoReviews" runat="server" CssClass="empty-state" Text="No reviews yet. Learners enrolled in this course can leave the first one." />
    <asp:Repeater ID="rptReviews" runat="server"><ItemTemplate>
        <article class="review-card"><h3><span><%#: Eval("FullName") %></span><span class="stars" aria-label='<%#: Eval("Rating") + " out of 5 stars" %>'><%# Stars(Eval("Rating")) %></span></h3>
        <p class="preserve-lines"><%#: Eval("Comment") %></p><p class="muted"><small>Posted <%#: Eval("PostedDate","{0:d MMMM yyyy}") %><%#: Eval("EditedDate") == DBNull.Value ? "" : ", edited" %></small></p></article>
    </ItemTemplate></asp:Repeater>
    <asp:Panel ID="pnlReview" runat="server" Visible="false" CssClass="form-card">
        <h3>Your review</h3>
        <p class="muted">Reviews are visible to everyone and show your name. Be specific about what helped you.</p>
        <asp:ValidationSummary ID="vsReview" runat="server" ValidationGroup="Review" />
        <div class="field"><asp:Label ID="lblRating" runat="server" AssociatedControlID="txtRating" Text="Rating from 1 (poor) to 5 (excellent)" /><asp:TextBox ID="txtRating" runat="server" TextMode="Number" min="1" max="5" style="max-width:120px" /><asp:RequiredFieldValidator ID="rfvRating" runat="server" ControlToValidate="txtRating" ValidationGroup="Review" ErrorMessage="Enter a rating." Display="Dynamic" /><asp:RangeValidator ID="rvRating" runat="server" ControlToValidate="txtRating" Type="Integer" MinimumValue="1" MaximumValue="5" ValidationGroup="Review" ErrorMessage="Rating must be a whole number from 1 to 5." Display="Dynamic" /></div>
        <div class="field"><asp:Label ID="lblComment" runat="server" AssociatedControlID="txtComment" Text="Comment (10 to 1000 characters)" /><asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine" Rows="5" /><asp:RequiredFieldValidator ID="rfvComment" runat="server" ControlToValidate="txtComment" ValidationGroup="Review" ErrorMessage="Enter a comment." Display="Dynamic" /><asp:RegularExpressionValidator ID="revComment" runat="server" ControlToValidate="txtComment" ValidationExpression="^[\s\S]{10,1000}$" ValidationGroup="Review" ErrorMessage="Comment must be 10 to 1000 characters." Display="Dynamic" /></div>
        <div class="actions"><asp:Button ID="btnReview" runat="server" Text="Save review" ValidationGroup="Review" OnClick="SaveReview" /><asp:Button ID="btnDeleteReview" runat="server" Text="Delete my review" Visible="false" ValidationGroup="RemoveReview" OnClick="DeleteReview" OnClientClick="return confirm('Delete your review?');" /><asp:HyperLink ID="lnkCancelReview" runat="server" Text="Cancel" CssClass="button secondary" /></div>
    </asp:Panel>
</section>
</asp:Content>
