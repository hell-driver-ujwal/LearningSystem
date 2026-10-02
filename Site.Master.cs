using System;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class SiteMaster : MasterPage
    {
        public BreadcrumbItem[] Breadcrumb { get; set; }
        // Extra CSS class for <main>; the home page uses "home" for a full-width hero.
        public string MainClassName { get; set; }
        protected string MainClass { get { return String.IsNullOrEmpty(MainClassName) ? "" : " " + MainClassName; } }

        private string CurrentPath { get { return Request.AppRelativeCurrentExecutionFilePath; } }

        // Shown in the sidebar for signed-in users; filled while the account links are built.
        protected string SidebarFirstName { get; private set; }
        protected string SidebarInitial { get; private set; }
        protected string SidebarRole { get; private set; }

        // Body class: signed-in users get the sidebar layout. Lesson and activity pages use a slim
        // icon-only sidebar so the learning content has more room.
        protected string BodyClass
        {
            get
            {
                if (!pnlWorkspace.Visible) return "public";
                bool memberPage = CurrentPath.StartsWith("~/Member/", StringComparison.OrdinalIgnoreCase);
                bool accountPage = CurrentPath.EndsWith("/Profile.aspx", StringComparison.OrdinalIgnoreCase) || CurrentPath.EndsWith("/ChangePassword.aspx", StringComparison.OrdinalIgnoreCase);
                return memberPage && !accountPage ? "has-sidebar is-rail" : "has-sidebar";
            }
        }
        private bool IsHome { get { return CurrentPath.Equals("~/Default.aspx", StringComparison.OrdinalIgnoreCase); } }

        // "Course catalogue | Inkwell"; the home page sets its own complete title.
        protected string PageTitle
        {
            get
            {
                string title = String.IsNullOrWhiteSpace(Page.Title) ? UiHelper.SiteName : Page.Title;
                return IsHome ? title : title + " | " + UiHelper.SiteName;
            }
        }

        // One canonical address per page; only the course or lesson id is kept from the query string.
        protected string CanonicalUrl
        {
            get
            {
                string url = UiHelper.SiteOrigin + VirtualPathUtility.ToAbsolute(CurrentPath);
                int id;
                if (Int32.TryParse(Request.QueryString["id"], out id) && id > 0) url += "?id=" + id;
                return url;
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            string path = CurrentPath;
            bool protectedPage = path.StartsWith("~/Payment/", StringComparison.OrdinalIgnoreCase) || path.StartsWith("~/Member/", StringComparison.OrdinalIgnoreCase)
                || path.StartsWith("~/Learner/", StringComparison.OrdinalIgnoreCase)
                || path.StartsWith("~/Teacher/", StringComparison.OrdinalIgnoreCase)
                || path.StartsWith("~/Admin/", StringComparison.OrdinalIgnoreCase);
            if (protectedPage)
            {
                // Master Init runs before page Load and save handlers.
                try { AccessHelper.RequireRole(new[] { "Learner", "Teacher", "Admin" }); }
                catch (SqlException) { Response.Redirect("~/Error.aspx"); return; }
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.Cache.SetNoStore();
            }
            // Error pages shown through customErrors run without session state.
            if (Context.Session != null) Page.ViewStateUserKey = Session.SessionID;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string role = CurrentUserHelper.GetRole();
            BuildPrimaryNavigation(role);
            BuildAccount(role);
            BuildWorkspace(role);
            BuildFooter();
            navBreadcrumb.Visible = !IsHome;
            BreadcrumbHelper.Render(phBreadcrumb, new[] {
                new BreadcrumbItem { Text = "Home", Url = "~/Default.aspx" },
                new BreadcrumbItem { Text = Page.Title }
            });
        }

        private void BuildPrimaryNavigation(string role)
        {
            if (role != "") AddLink(phNavigation, "Dashboard", CurrentUserHelper.GetDashboardUrl());
            AddLink(phNavigation, "Courses", "~/Courses.aspx");
            AddLink(phNavigation, "Help", "~/Help.aspx");
            if (role == "")
            {
                AddLink(phNavigation, "About", "~/About.aspx");
                AddLink(phNavigation, "Contact", "~/Contact.aspx");
            }
        }

        private void BuildAccount(string role)
        {
            if (role == "")
            {
                AddLink(phAccount, "Log in", "~/Account/Login.aspx");
                phAccount.Controls.Add(new HyperLink { Text = "Join for free", NavigateUrl = "~/Account/Register.aspx", CssClass = "button" });
                return;
            }
            string name = Context.Session == null ? CurrentUserHelper.GetFullName() : Convert.ToString(Session["FullName"]);
            SidebarFirstName = name.Trim().Split(' ')[0];
            SidebarInitial = UiHelper.Initial(name);
            SidebarRole = UiHelper.RoleLabel(role);
            phAccount.Controls.Add(new LiteralControl("<a class=\"user-chip\" href=\"" + ResolveUrl("~/Member/Profile.aspx") + "\" title=\"My profile\"><span class=\"avatar\" aria-hidden=\"true\">"
                + HttpUtility.HtmlEncode(UiHelper.Initial(name)) + "</span><span><span class=\"name\">" + HttpUtility.HtmlEncode(name)
                + "</span><span class=\"role-label\">" + HttpUtility.HtmlEncode(UiHelper.RoleLabel(role)) + "</span></span></a>"));
            phAccount.Controls.Add(new LiteralControl("<a href=\"" + ResolveUrl("~/Account/Logout.aspx") + "\">" + UiHelper.Icon("logout") + " Log out</a>"));
        }

        // A second navigation row with the tools for the signed-in role.
        private void BuildWorkspace(string role)
        {
            pnlWorkspace.Visible = role != "";
            if (role == "Learner")
            {
                AddLink(phWorkspace, "Overview", "~/Learner/Dashboard.aspx", 0, "home");
                AddLink(phWorkspace, "My courses", "~/Learner/MyCourses.aspx", 0, "layers");
                AddLink(phWorkspace, "My results", "~/Learner/MyResults.aspx", 0, "chart");
                AddLink(phWorkspace, "Bookmarks", "~/Learner/MyBookmarks.aspx", 0, "bookmark");
                AddLink(phWorkspace, "Payments", "~/Learner/MyPayments.aspx", 0, "wallet");
            }
            else if (role == "Teacher")
            {
                AddLink(phWorkspace, "Overview", "~/Teacher/Dashboard.aspx", 0, "home");
                AddLink(phWorkspace, "My courses", "~/Teacher/MyCourses.aspx", 0, "layers");
                AddLink(phWorkspace, "Create course", "~/Teacher/CourseEdit.aspx", 0, "plus");
                AddLink(phWorkspace, "Results", "~/Teacher/Results.aspx", 0, "chart");
            }
            else if (role == "Admin")
            {
                int pending = 0, unread = 0;
                try
                {
                    pending = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.[User] WHERE Role='Teacher' AND Status='Pending'", null));
                    unread = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.ContactMessage WHERE IsRead=0", null));
                }
                catch (SqlException) { }
                AddLink(phWorkspace, "Overview", "~/Admin/Dashboard.aspx", 0, "home");
                AddLink(phWorkspace, "Users", "~/Admin/Users.aspx", 0, "users");
                AddLink(phWorkspace, "Applications", "~/Admin/TeacherApplications.aspx", pending, "award");
                AddLink(phWorkspace, "All courses", "~/Admin/Courses.aspx", 0, "book");
                AddLink(phWorkspace, "Activities", "~/Admin/Activities.aspx", 0, "puzzle");
                AddLink(phWorkspace, "Subjects", "~/Admin/Subjects.aspx", 0, "compass");
                AddLink(phWorkspace, "My courses", "~/Teacher/MyCourses.aspx", 0, "layers");
                AddLink(phWorkspace, "Messages", "~/Admin/Messages.aspx", unread, "mail");
                AddLink(phWorkspace, "FAQs", "~/Admin/FAQ.aspx", 0, "help");
                AddLink(phWorkspace, "Payments", "~/Admin/Payments.aspx", 0, "wallet");
                AddLink(phWorkspace, "Analytics", "~/Admin/Analytics.aspx", 0, "chart");
            }
            if (role != "") AddLink(phWorkspace, "Profile", "~/Member/Profile.aspx", 0, "user");
        }

        private void BuildFooter()
        {
            phFooterLearn.Controls.Add(new LiteralControl("<ul>"));
            AddFooterLink(phFooterLearn, "All courses", "~/Courses.aspx");
            AddFooterLink(phFooterLearn, "Free courses", "~/Courses.aspx?price=free");
            AddFooterLink(phFooterLearn, "Become a lecturer", "~/Account/Register.aspx?as=lecturer");
            AddFooterLink(phFooterLearn, "Browse by subject", "~/Default.aspx#subjects");
            phFooterLearn.Controls.Add(new LiteralControl("</ul>"));
            phFooter.Controls.Add(new LiteralControl("<ul>"));
            AddFooterLink(phFooter, "Help and FAQ", "~/Help.aspx");
            AddFooterLink(phFooter, "Contact us", "~/Contact.aspx");
            AddFooterLink(phFooter, "Site map", "~/SiteMap.aspx");
            AddFooterLink(phFooter, "Keyboard shortcuts", "~/Help.aspx#shortcuts");
            phFooter.Controls.Add(new LiteralControl("</ul>"));
            phFooterLegal.Controls.Add(new LiteralControl("<ul>"));
            AddFooterLink(phFooterLegal, "About us", "~/About.aspx");
            AddFooterLink(phFooterLegal, "Privacy policy", "~/Privacy.aspx");
            AddFooterLink(phFooterLegal, "Terms of use", "~/Terms.aspx");
            phFooterLegal.Controls.Add(new LiteralControl("</ul>"));
        }

        protected override void OnPreRender(EventArgs e)
        {
            ImproveControls(MainContent);
            if (Breadcrumb != null) BreadcrumbHelper.Render(phBreadcrumb, Breadcrumb);
            PageMessage message = MessageHelper.TakeMessage();
            if (message != null)
            {
                pnlMessage.Visible = true;
                pnlMessage.CssClass = message.IsError ? "message error" : "message success";
                pnlMessage.Attributes["role"] = message.IsError ? "alert" : "status";
                // The message text is encoded here; only the fixed icon markup is added around it.
                litMessage.Mode = LiteralMode.PassThrough;
                litMessage.Text = UiHelper.Icon(message.IsError ? "help" : "check-circle") + "<span><span class=\"visually-hidden\">"
                    + (message.IsError ? "Error: " : "Success: ") + "</span>" + HttpUtility.HtmlEncode(message.Text) + "</span>";
            }
            // Count a page view once per normal page load (not on postbacks).
            if (!IsPostBack && Request.HttpMethod == "GET") AnalyticsHelper.RecordView(CurrentPath, CurrentUserHelper.GetRole());
            base.OnPreRender(e);
        }

        // Apply consistent presentation to existing controls without changing their event handlers or IDs.
        private void ImproveControls(Control parent)
        {
            foreach (Control control in parent.Controls)
            {
                Button button = control as Button;
                if (button != null)
                {
                    string text = button.Text.ToLowerInvariant();
                    if (text.StartsWith("delete") || text.StartsWith("remove") || text.StartsWith("leave") || text.StartsWith("reject") || text.StartsWith("deactivate")) AddStyle(button, "danger");
                    else if (text.StartsWith("cancel") || text.StartsWith("back") || text.StartsWith("previous") || text.StartsWith("preview") || text.StartsWith("clear")) AddStyle(button, "secondary");
                    else if (text.StartsWith("edit") || text.StartsWith("view") || text.StartsWith("unpublish") || text.StartsWith("unlock") || text.StartsWith("reply") || text.StartsWith("mark as read")) AddStyle(button, "subtle");
                }
                BaseValidator validator = control as BaseValidator;
                if (validator != null) { AddStyle(validator, "validation"); validator.ForeColor = System.Drawing.Color.Empty; validator.SetFocusOnError = true; if (validator.Display == ValidatorDisplay.Static) validator.Display = ValidatorDisplay.Dynamic; }
                ValidationSummary summary = control as ValidationSummary;
                if (summary != null) { AddStyle(summary, "validation-summary"); summary.ForeColor = System.Drawing.Color.Empty; summary.Attributes["role"] = "alert"; if (String.IsNullOrEmpty(summary.HeaderText)) summary.HeaderText = "Please check the following:"; }
                GridView grid = control as GridView;
                if (grid != null)
                {
                    grid.UseAccessibleHeader = true; grid.PagerStyle.CssClass = "pager"; grid.GridLines = GridLines.None; grid.CellSpacing = -1;
                    if (grid.HeaderRow != null) grid.HeaderRow.TableSection = TableRowSection.TableHeader;
                    foreach (GridViewRow row in grid.Rows)
                        foreach (TableCell cell in row.Cells)
                        {
                            string status = HttpUtility.HtmlDecode(cell.Text);
                            if (cell.Controls.Count == 0 && (status == "Draft" || status == "Published" || status == "Active" || status == "Pending" || status == "Rejected" || status == "Deactivated" || status == "Best" || status == "Acceptable" || status == "Poor" || status == "Complete" || status == "Failed" || status == "Canceled"))
                                cell.Text = "<span class=\"badge badge-" + status.ToLowerInvariant() + "\">" + HttpUtility.HtmlEncode(status) + "</span>";
                            else if (cell.Controls.Count == 0 && status == "Teacher")
                                cell.Text = "Lecturer";
                        }
                }
                ImproveControls(control);
            }
        }
        private static void AddStyle(WebControl control, string name)
        {
            if (!(" " + control.CssClass + " ").Contains(" " + name + " ")) control.CssClass = (control.CssClass + " " + name).Trim();
        }

        // Sidebar links pass an icon name; the label then sits in its own span so the slim sidebar can hide it visually.
        private void AddLink(PlaceHolder target, string label, string url, int count = 0, string icon = null)
        {
            string path = url.Split('?')[0];
            bool current = path.Equals(CurrentPath, StringComparison.OrdinalIgnoreCase);
            string html = "<a href=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl(url)) + "\"" + (current ? " aria-current=\"page\"" : "");
            if (icon == null) html += ">" + HttpUtility.HtmlEncode(label);
            else html += " title=\"" + HttpUtility.HtmlAttributeEncode(label) + "\">" + UiHelper.Icon(icon) + "<span class=\"nav-label\">" + HttpUtility.HtmlEncode(label) + "</span>";
            if (count > 0) html += "<span class=\"count\" aria-label=\"" + count + " waiting\">" + count + "</span>";
            target.Controls.Add(new LiteralControl(html + "</a>"));
        }

        private void AddFooterLink(PlaceHolder target, string label, string url)
        {
            target.Controls.Add(new LiteralControl("<li><a href=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl(url)) + "\">" + HttpUtility.HtmlEncode(label) + "</a></li>"));
        }
    }
}
