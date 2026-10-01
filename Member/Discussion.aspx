<%@ Page Title="Discussion" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Discussion.aspx.cs" Inherits="LearningSystem.Member.Discussion" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<asp:Panel ID="pnlPreview" runat="server" CssClass="preview-banner" Visible="false">Preview — posts, replies and moderation are disabled; nothing is saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></asp:Panel>
<p class="preserve-lines"><asp:Literal ID="litPrompt" runat="server" Mode="Encode" /></p>
<p><asp:Literal ID="litStatus" runat="server" Mode="Encode" /></p>
<h2>Posts and replies</h2><asp:Label ID="lblEmpty" runat="server" Text="No posts yet." />
<asp:Repeater ID="rptPosts" runat="server" OnItemDataBound="BindPost" OnItemCommand="PostCommand"><ItemTemplate>
<article class='<%# Eval("ParentPostID") == DBNull.Value ? "topic-card" : "topic-card discussion-reply" %>'>
<h3><%#: Eval("FullName") %><%#: Eval("ParentPostID") == DBNull.Value ? " — Post" : " — Reply to post " + Eval("ParentPostID") %></h3>
<p><%#: String.Format("{0:yyyy-MM-dd HH:mm:ss} UTC", Eval("PostedDate")) %><%#: Eval("EditedDate") == DBNull.Value ? "" : String.Format("; edited {0:yyyy-MM-dd HH:mm:ss} UTC", Eval("EditedDate")) %></p>
<p class="preserve-lines"><%#: Eval("Content") %></p>
<div class="actions"><asp:Button ID="btnReply" runat="server" Text="Reply" CommandName="ReplyPost" CommandArgument='<%# Eval("PostID") %>' ValidationGroup="Action" />
<asp:Button ID="btnEdit" runat="server" Text="Edit" CommandName="EditPost" CommandArgument='<%# Eval("PostID") %>' ValidationGroup="Action" />
<asp:Button ID="btnRemove" runat="server" Text="Delete / remove" CommandName="RemovePost" CommandArgument='<%# Eval("PostID") %>' ValidationGroup="Action" OnClientClick="return confirm('Remove this post and ALL its replies, including replies by other authors?');" /></div>
</article></ItemTemplate></asp:Repeater>
<asp:Panel ID="pnlEditor" runat="server" CssClass="form-card"><h2><asp:Literal ID="litEditor" runat="server" Mode="Encode" Text="Write a post" /></h2>
<asp:ValidationSummary ID="vsPost" runat="server" ValidationGroup="Post" />
<asp:Label ID="lblContent" runat="server" AssociatedControlID="txtContent" Text="Post (2–2000 characters)" /><asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5" MaxLength="2000" />
<asp:RequiredFieldValidator ID="rfvContent" runat="server" ControlToValidate="txtContent" ValidationGroup="Post" ErrorMessage="Enter a post." />
<asp:RegularExpressionValidator ID="revContent" runat="server" ControlToValidate="txtContent" ValidationGroup="Post" ValidationExpression="^[\s\S]{2,2000}$" ErrorMessage="Post must be 2–2000 characters." />
<div class="actions"><asp:Button ID="btnSave" runat="server" Text="Save post" ValidationGroup="Post" OnClick="SavePost" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /></div>
</asp:Panel><p><asp:HyperLink ID="lnkBack" runat="server" Text="Back to course / activities" /></p>
</asp:Content>

