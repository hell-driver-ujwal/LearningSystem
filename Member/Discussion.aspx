<%@ Page Title="Discussion" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Discussion.aspx.cs" Inherits="LearningSystem.Member.Discussion" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false"><span>Preview mode. Posting, replying and moderation are switched off and nothing is saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></span></asp:Panel>
<div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("Discussion") %><div><p class="eyebrow">Discussion</p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1></div></div>
<section class="lesson-tip" aria-label="Discussion prompt"><p class="preserve-lines"><asp:Literal ID="litPrompt" runat="server" Mode="Encode" /></p></section>
<p class="muted"><asp:Literal ID="litStatus" runat="server" Mode="Encode" /></p>
<asp:Panel ID="pnlEditor" runat="server" CssClass="form-card wide"><h2><asp:Literal ID="litEditor" runat="server" Mode="Encode" Text="Share your answer" /></h2>
    <asp:ValidationSummary ID="vsPost" runat="server" ValidationGroup="Post" />
    <asp:Label ID="lblContent" runat="server" AssociatedControlID="txtContent" Text="Your post (2 to 2000 characters)" /><asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5" MaxLength="2000" />
    <span class="hint">Be kind and specific. Everyone enrolled in this course and the lecturer can read your post.</span>
    <asp:RequiredFieldValidator ID="rfvContent" runat="server" ControlToValidate="txtContent" ValidationGroup="Post" ErrorMessage="Write something before posting." Display="Dynamic" />
    <asp:RegularExpressionValidator ID="revContent" runat="server" ControlToValidate="txtContent" ValidationGroup="Post" ValidationExpression="^[\s\S]{2,2000}$" ErrorMessage="Posts must be 2 to 2000 characters." Display="Dynamic" />
    <div class="actions"><asp:Button ID="btnSave" runat="server" Text="Post" ValidationGroup="Post" OnClick="SavePost" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /></div>
</asp:Panel>
<h2><asp:Literal ID="litCount" runat="server" Mode="Encode" /></h2>
<asp:Label ID="lblEmpty" runat="server" CssClass="empty-state" Text="No posts yet. Be the first to answer the prompt." />
<asp:Repeater ID="rptPosts" runat="server" OnItemDataBound="BindPost" OnItemCommand="PostCommand"><ItemTemplate>
<article class='<%# Eval("ParentPostID") == DBNull.Value ? "post" : "post discussion-reply" %>' id='<%# "post-" + Eval("PostID") %>'>
    <div class="post-head"><span class="avatar" aria-hidden="true"><%#: LearningSystem.Helpers.UiHelper.Initial(Convert.ToString(Eval("FullName"))) %></span>
        <div><strong><%#: Eval("FullName") %></strong> <%# AuthorTag(Eval("UserID"), Eval("Role")) %><br />
        <span class="muted"><%#: Eval("ParentPostID") == DBNull.Value ? "Posted " : "Replied " %><%#: LearningSystem.Helpers.UiHelper.Ago((DateTime)Eval("PostedDate")) %><%#: Eval("EditedDate") == DBNull.Value ? "" : " (edited)" %></span></div></div>
    <p class="preserve-lines"><%#: Eval("Content") %></p>
    <div class="actions"><asp:Button ID="btnReply" runat="server" Text="Reply" CommandName="ReplyPost" CommandArgument='<%# Eval("PostID") %>' ValidationGroup="Action" />
    <asp:Button ID="btnEdit" runat="server" Text="Edit" CommandName="EditPost" CommandArgument='<%# Eval("PostID") %>' ValidationGroup="Action" />
    <asp:Button ID="btnRemove" runat="server" Text="Delete" CommandName="RemovePost" CommandArgument='<%# Eval("PostID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this post and all of its replies, including replies by other people?');" /></div>
</article></ItemTemplate></asp:Repeater>
<p><asp:HyperLink ID="lnkBack" runat="server" Text="Back to the course" /></p>
</asp:Content>
