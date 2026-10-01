<%@ Page Title="Free preview" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Preview.aspx.cs" Inherits="LearningSystem.Preview" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="lesson-layout">
<article>
    <div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("Text") %><div><p class="eyebrow">Free preview lesson</p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1></div></div>
    <section class="learning-content" aria-label="Lesson content"><asp:PlaceHolder ID="phViewer" runat="server" /></section>
    <div class="lesson-footer">
        <p style="margin:0">Enjoying this lesson? Enrol to unlock every lesson and activity, and to save your progress.</p>
        <div class="actions"><asp:HyperLink ID="lnkExit" runat="server" Text="See the full course" CssClass="button" /><a href="Account/Register.aspx">Create a free account</a></div>
    </div>
</article>
</div>
</asp:Content>
