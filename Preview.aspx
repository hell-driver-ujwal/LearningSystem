<%@ Page Title="Free preview" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Preview.aspx.cs" Inherits="LearningSystem.Preview" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1><p class="message">Free preview — nothing is saved to learning progress.</p>
<asp:PlaceHolder ID="phViewer" runat="server" /><p><asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview / back to course" /></p>
</asp:Content>
