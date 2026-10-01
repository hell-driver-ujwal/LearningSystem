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
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            string path = Request.AppRelativeCurrentExecutionFilePath;
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
            Page.ViewStateUserKey = Session.SessionID;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            string role = CurrentUserHelper.GetRole();
            if (role != "Admin") AddLink(phNavigation, "Courses", "~/Courses.aspx");
            if (role != "") AddLink(phNavigation, "Dashboard", CurrentUserHelper.GetDashboardUrl());
            if (role == "Learner")
            {
                AddLink(phNavigation, "My Courses", "~/Learner/MyCourses.aspx");
                AddLink(phNavigation, "My Results", "~/Learner/MyResults.aspx");
                AddLink(phNavigation, "My Payments", "~/Learner/MyPayments.aspx");
                AddLink(phNavigation, "My Bookmarks", "~/Learner/MyBookmarks.aspx");
            }
            if (role == "Teacher")
            {
                AddLink(phNavigation, "My Courses", "~/Teacher/MyCourses.aspx");
                AddLink(phNavigation, "Results", "~/Teacher/Results.aspx");
            }
            if (role == "Admin")
            {
                AddLink(phNavigation, "Payments", "~/Admin/Payments.aspx");
                AddLink(phNavigation, "Users", "~/Admin/Users.aspx");
                AddLink(phNavigation, "Applications", "~/Admin/TeacherApplications.aspx");
                AddLink(phNavigation, "Subjects", "~/Admin/Subjects.aspx");
                AddLink(phNavigation, "Courses", "~/Admin/Courses.aspx");
                AddLink(phNavigation, "Activities", "~/Admin/Activities.aspx");
                AddLink(phNavigation, "FAQs", "~/Admin/FAQ.aspx");
                try{int unread=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.ContactMessage WHERE IsRead=0",null));AddLink(phNavigation,"Messages ("+unread+" unread)","~/Admin/Messages.aspx");}
                catch(SqlException){AddLink(phNavigation,"Messages","~/Admin/Messages.aspx");}
            }
            AddLink(phNavigation, "Help", "~/Help.aspx");
            if (role == "")
            {
                AddLink(phNavigation, "About", "~/About.aspx");
                AddLink(phAccount, "Log in", "~/Account/Login.aspx");
                AddLink(phAccount, "Register", "~/Account/Register.aspx");
            }
            else
            {
                phAccount.Controls.Add(new LiteralControl("<span class=\"user-name\">" + HttpUtility.HtmlEncode(Convert.ToString(Session["FullName"])) + "</span>"));
                AddLink(phAccount, "Profile", "~/Member/Profile.aspx");
                AddLink(phAccount, "Log out", "~/Account/Logout.aspx");
            }
            AddLink(phFooter, "About", "~/About.aspx");
            AddLink(phFooter, "Help", "~/Help.aspx");
            AddLink(phFooter, "Contact", "~/Contact.aspx");
            AddLink(phFooter, "Site Map", "~/SiteMap.aspx");
            navBreadcrumb.Visible = !Request.AppRelativeCurrentExecutionFilePath.Equals("~/Default.aspx", StringComparison.OrdinalIgnoreCase);
            BreadcrumbHelper.Render(phBreadcrumb, new[] {
                new BreadcrumbItem { Text = "Home", Url = "~/Default.aspx" },
                new BreadcrumbItem { Text = Page.Title }
            });
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
                litMessage.Text = (message.IsError ? "Error: " : "Success: ") + message.Text;
            }
            base.OnPreRender(e);
        }
        // Apply consistent presentation to existing controls without changing their event handlers or IDs.
        private void ImproveControls(Control parent)
        {
            foreach(Control control in parent.Controls)
            {
                Button button=control as Button;
                if(button!=null)
                {
                    string text=button.Text.ToLowerInvariant();
                    if(text.StartsWith("delete") || text.StartsWith("remove") || text.StartsWith("leave"))AddStyle(button,"danger");
                    else if(text.StartsWith("cancel") || text.StartsWith("back") || text.StartsWith("previous") || text.StartsWith("preview"))AddStyle(button,"secondary");
                    else if(text.StartsWith("edit") || text.StartsWith("view"))AddStyle(button,"subtle");
                }
                BaseValidator validator=control as BaseValidator;
                if(validator!=null){AddStyle(validator,"validation");validator.ForeColor=System.Drawing.Color.Empty;validator.SetFocusOnError=true;}
                ValidationSummary summary=control as ValidationSummary;
                if(summary!=null){AddStyle(summary,"validation-summary");summary.ForeColor=System.Drawing.Color.Empty;summary.Attributes["role"]="alert";}
                GridView grid=control as GridView;
                if(grid!=null)
                {
                    grid.UseAccessibleHeader=true;grid.PagerStyle.CssClass="pager";
                    if(grid.HeaderRow!=null)grid.HeaderRow.TableSection=TableRowSection.TableHeader;
                    foreach(GridViewRow row in grid.Rows)
                        foreach(TableCell cell in row.Cells)
                        {
                            string status=HttpUtility.HtmlDecode(cell.Text);
                            if(cell.Controls.Count==0 && (status=="Draft" || status=="Published" || status=="Active" || status=="Pending" || status=="Rejected" || status=="Deactivated" || status=="Best" || status=="Acceptable" || status=="Poor"))
                                cell.Text="<span class=\"badge badge-"+status.ToLowerInvariant()+"\">"+HttpUtility.HtmlEncode(status)+"</span>";
                        }
                }
                ImproveControls(control);
            }
        }
        private static void AddStyle(WebControl control,string name)
        {
            if(!(" "+control.CssClass+" ").Contains(" "+name+" "))control.CssClass=(control.CssClass+" "+name).Trim();
        }
        private void AddLink(PlaceHolder target, string label, string url)
        {
            // Future-phase pages are visible as disabled labels, never broken links.
            bool available = System.IO.File.Exists(Server.MapPath(url))
                ;
            if (available) target.Controls.Add(new HyperLink { Text = HttpUtility.HtmlEncode(label), NavigateUrl = url });
            else target.Controls.Add(new LiteralControl("<span class=\"nav-pending\" aria-disabled=\"true\" title=\"Available in a later phase\">" + HttpUtility.HtmlEncode(label) + "</span>"));
        }
    }
}

