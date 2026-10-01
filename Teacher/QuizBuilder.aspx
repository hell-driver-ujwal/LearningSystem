<%@ Page Title="Quiz editor" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuizBuilder.aspx.cs" Inherits="LearningSystem.Teacher.QuizBuilder" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div class="activity-header"><%= LearningSystem.Helpers.UiHelper.TypeMark("Quiz") %><div><p class="eyebrow">Course builder</p><h1>Quiz builder</h1></div></div></div>
<asp:Label ID="lblLock" runat="server" Visible="false" CssClass="lock-note" Text="Attempts exist: quiz structure, order, time and attempt limits are locked. Title, description and publication remain editable." />
<section class="form-card"><h2>Settings</h2><asp:ValidationSummary ID="vsSettings" runat="server" ValidationGroup="Settings" />
<div class="field"><asp:Label ID="lblTitle" runat="server" AssociatedControlID="txtTitle" Text="Title" /><asp:TextBox ID="txtTitle" runat="server" TextMode="SingleLine" MaxLength="100" />
<asp:RegularExpressionValidator ID="revTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Settings" ValidationExpression="^[\s\S]{3,100}$" ErrorMessage="Title must be 3 to 100 characters." />
<asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Settings" ErrorMessage="Enter Title." />
</div>
<div class="field"><asp:Label ID="lblDescription" runat="server" AssociatedControlID="txtDescription" Text="Description / prompt" /><asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" MaxLength="1000" />
<asp:RegularExpressionValidator ID="revDescription" runat="server" ControlToValidate="txtDescription" ValidationGroup="Settings" ValidationExpression="^[\s\S]{0,1000}$" ErrorMessage="Description / prompt must be 0 to 1000 characters." />
</div>
<div class="field"><asp:Label ID="lblOrder" runat="server" AssociatedControlID="txtOrder" Text="Activity order" /><asp:TextBox ID="txtOrder" runat="server" TextMode="Number" Text="1" />
<asp:RequiredFieldValidator ID="rfvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Settings" ErrorMessage="Enter Activity order." />
<asp:RangeValidator ID="rvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Settings" Type="Integer" MinimumValue="1" MaximumValue="2147483647" ErrorMessage="Activity order must be 1 to 2147483647." /></div>
<asp:Panel ID="pnlQuiz" runat="server">
<div class="field"><asp:Label ID="lblMinutes" runat="server" AssociatedControlID="txtMinutes" Text="Time limit minutes (0 = untimed)" /><asp:TextBox ID="txtMinutes" runat="server" TextMode="Number" Text="0" />
<asp:RequiredFieldValidator ID="rfvMinutes" runat="server" ControlToValidate="txtMinutes" ValidationGroup="Settings" ErrorMessage="Enter Time limit minutes (0 = untimed)." />
<asp:RangeValidator ID="rvMinutes" runat="server" ControlToValidate="txtMinutes" ValidationGroup="Settings" Type="Integer" MinimumValue="0" MaximumValue="180" ErrorMessage="Time limit minutes (0 = untimed) must be 0 to 180." /></div>
<div class="field"><asp:Label ID="lblAttempts" runat="server" AssociatedControlID="txtAttempts" Text="Maximum attempts (0 = unlimited)" /><asp:TextBox ID="txtAttempts" runat="server" TextMode="Number" Text="0" />
<asp:RequiredFieldValidator ID="rfvAttempts" runat="server" ControlToValidate="txtAttempts" ValidationGroup="Settings" ErrorMessage="Enter Maximum attempts (0 = unlimited)." />
<asp:RangeValidator ID="rvAttempts" runat="server" ControlToValidate="txtAttempts" ValidationGroup="Settings" Type="Integer" MinimumValue="0" MaximumValue="10" ErrorMessage="Maximum attempts (0 = unlimited) must be 0 to 10." /></div>
</asp:Panel><asp:Panel ID="pnlClosed" runat="server"><asp:CheckBox ID="chkClosed" runat="server" Text="Closed (read only for authors)" /></asp:Panel>
<div class="field"><asp:Label ID="lblStatus" runat="server" AssociatedControlID="ddlStatus" Text="Publication" /><asp:DropDownList ID="ddlStatus" runat="server"><asp:ListItem Text="Draft" /><asp:ListItem Text="Published" /></asp:DropDownList></div><div class="actions"><asp:Button ID="btnSave" runat="server" Text="Save settings" ValidationGroup="Settings" OnClick="SaveSettings" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /><asp:HyperLink ID="lnkPreview" runat="server" Text="Preview" /><asp:Button ID="btnDelete" runat="server" Text="Delete activity" ValidationGroup="Action" OnClick="DeleteActivity" OnClientClick="return confirm('Delete this activity and all its content/posts? Attempts block deletion.');" /></div></section>
<asp:Panel ID="pnlQuestions" runat="server"><h2>Questions</h2><div class="table-scroll" role="region" aria-label="Quiz questions" tabindex="0"><asp:GridView ID="gvQuestions" runat="server" AutoGenerateColumns="false" Caption="Quiz questions" UseAccessibleHeader="true" EmptyDataText="No questions yet. Add a question before publishing." OnRowCommand="QuestionCommand"><Columns><asp:BoundField DataField="QuestionText" HeaderText="Question" HtmlEncode="true" /><asp:BoundField DataField="Marks" HeaderText="Marks" /><asp:BoundField DataField="SortOrder" HeaderText="Order" /><asp:TemplateField HeaderText="Actions"><ItemTemplate><asp:Button ID="btnEditQuestion" runat="server" Text="Edit" CommandName="EditQuestion" CommandArgument='<%# Eval("QuestionID") %>' ValidationGroup="Action" /><asp:Button ID="btnDeleteQuestion" runat="server" Text="Delete" CommandName="DeleteQuestion" CommandArgument='<%# Eval("QuestionID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this question and its options?');" /></ItemTemplate></asp:TemplateField></Columns></asp:GridView></div><asp:Panel ID="pnlQuestionForm" runat="server" CssClass="form-card"><h3>Add / edit question</h3><asp:ValidationSummary ID="vsQuestion" runat="server" ValidationGroup="Question" />
<div class="field"><asp:Label ID="lblQuestion" runat="server" AssociatedControlID="txtQuestion" Text="Question" /><asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine" MaxLength="500" />
<asp:RegularExpressionValidator ID="revQuestion" runat="server" ControlToValidate="txtQuestion" ValidationGroup="Question" ValidationExpression="^[\s\S]{5,500}$" ErrorMessage="Question must be 5 to 500 characters." />
<asp:RequiredFieldValidator ID="rfvQuestion" runat="server" ControlToValidate="txtQuestion" ValidationGroup="Question" ErrorMessage="Enter Question." />
</div>
<div class="field"><asp:Label ID="lblMarks" runat="server" AssociatedControlID="txtMarks" Text="Marks" /><asp:TextBox ID="txtMarks" runat="server" TextMode="Number" Text="1" />
<asp:RequiredFieldValidator ID="rfvMarks" runat="server" ControlToValidate="txtMarks" ValidationGroup="Question" ErrorMessage="Enter Marks." />
<asp:RangeValidator ID="rvMarks" runat="server" ControlToValidate="txtMarks" ValidationGroup="Question" Type="Integer" MinimumValue="1" MaximumValue="10" ErrorMessage="Marks must be 1 to 10." /></div>
<div class="field"><asp:Label ID="lblQuestionOrder" runat="server" AssociatedControlID="txtQuestionOrder" Text="Question order" /><asp:TextBox ID="txtQuestionOrder" runat="server" TextMode="Number" Text="1" />
<asp:RequiredFieldValidator ID="rfvQuestionOrder" runat="server" ControlToValidate="txtQuestionOrder" ValidationGroup="Question" ErrorMessage="Enter Question order." />
<asp:RangeValidator ID="rvQuestionOrder" runat="server" ControlToValidate="txtQuestionOrder" ValidationGroup="Question" Type="Integer" MinimumValue="1" MaximumValue="2147483647" ErrorMessage="Question order must be 1 to 2147483647." /></div>
<div class="field"><asp:Label ID="lblOption1" runat="server" AssociatedControlID="txtOption1" Text="Option 1" /><asp:TextBox ID="txtOption1" runat="server" TextMode="SingleLine" MaxLength="200" />
<asp:RegularExpressionValidator ID="revOption1" runat="server" ControlToValidate="txtOption1" ValidationGroup="Question" ValidationExpression="^[\s\S]{1,200}$" ErrorMessage="Option 1 must be 1 to 200 characters." />
<asp:RequiredFieldValidator ID="rfvOption1" runat="server" ControlToValidate="txtOption1" ValidationGroup="Question" ErrorMessage="Enter Option 1." />
</div>
<div class="field"><asp:Label ID="lblOption2" runat="server" AssociatedControlID="txtOption2" Text="Option 2" /><asp:TextBox ID="txtOption2" runat="server" TextMode="SingleLine" MaxLength="200" />
<asp:RegularExpressionValidator ID="revOption2" runat="server" ControlToValidate="txtOption2" ValidationGroup="Question" ValidationExpression="^[\s\S]{1,200}$" ErrorMessage="Option 2 must be 1 to 200 characters." />
<asp:RequiredFieldValidator ID="rfvOption2" runat="server" ControlToValidate="txtOption2" ValidationGroup="Question" ErrorMessage="Enter Option 2." />
</div>
<div class="field"><asp:Label ID="lblOption3" runat="server" AssociatedControlID="txtOption3" Text="Option 3" /><asp:TextBox ID="txtOption3" runat="server" TextMode="SingleLine" MaxLength="200" />
<asp:RegularExpressionValidator ID="revOption3" runat="server" ControlToValidate="txtOption3" ValidationGroup="Question" ValidationExpression="^[\s\S]{0,200}$" ErrorMessage="Option 3 must be 0 to 200 characters." />
</div>
<div class="field"><asp:Label ID="lblOption4" runat="server" AssociatedControlID="txtOption4" Text="Option 4" /><asp:TextBox ID="txtOption4" runat="server" TextMode="SingleLine" MaxLength="200" />
<asp:RegularExpressionValidator ID="revOption4" runat="server" ControlToValidate="txtOption4" ValidationGroup="Question" ValidationExpression="^[\s\S]{0,200}$" ErrorMessage="Option 4 must be 0 to 200 characters." />
</div>
<div class="field"><asp:Label ID="lblOption5" runat="server" AssociatedControlID="txtOption5" Text="Option 5" /><asp:TextBox ID="txtOption5" runat="server" TextMode="SingleLine" MaxLength="200" />
<asp:RegularExpressionValidator ID="revOption5" runat="server" ControlToValidate="txtOption5" ValidationGroup="Question" ValidationExpression="^[\s\S]{0,200}$" ErrorMessage="Option 5 must be 0 to 200 characters." />
</div>
<div class="field"><asp:Label ID="lblOption6" runat="server" AssociatedControlID="txtOption6" Text="Option 6" /><asp:TextBox ID="txtOption6" runat="server" TextMode="SingleLine" MaxLength="200" />
<asp:RegularExpressionValidator ID="revOption6" runat="server" ControlToValidate="txtOption6" ValidationGroup="Question" ValidationExpression="^[\s\S]{0,200}$" ErrorMessage="Option 6 must be 0 to 200 characters." />
</div>
<asp:CustomValidator ID="cvOptions" runat="server" ValidationGroup="Question" OnServerValidate="ValidateOptions" ErrorMessage="Enter 2 to 6 distinct options and select one nonempty correct option." />
<div class="field"><asp:Label ID="lblCorrect" runat="server" AssociatedControlID="ddlCorrect" Text="Correct option (exactly one)" /><asp:DropDownList ID="ddlCorrect" runat="server">
<asp:ListItem Text="Option 1" Value="1" />
<asp:ListItem Text="Option 2" Value="2" />
<asp:ListItem Text="Option 3" Value="3" />
<asp:ListItem Text="Option 4" Value="4" />
<asp:ListItem Text="Option 5" Value="5" />
<asp:ListItem Text="Option 6" Value="6" />
</asp:DropDownList></div><div class="actions"><asp:Button ID="btnSaveQuestion" runat="server" Text="Save question" ValidationGroup="Question" OnClick="SaveQuestion" /><asp:HyperLink ID="lnkCancelQuestion" runat="server" Text="Cancel question edit" NavigateUrl="QuizBuilder.aspx" /></div></asp:Panel></asp:Panel>
</asp:Content>


