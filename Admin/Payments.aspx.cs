using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Admin {
 public partial class Payments : Page {
  protected void Page_Load(object sender,EventArgs e) {AccessHelper.RequireRole(new[]{"Admin"});if(!IsPostBack)Bind();}
  private void Bind(){try{gvPayments.DataSource=PaymentHelper.History(ddlStatus.SelectedValue,true);gvPayments.DataBind();}
   catch(SqlException){MessageHelper.SetError("Payments are unavailable. Please try later.");}
   catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}}
  protected void Filter(object sender,EventArgs e){gvPayments.PageIndex=0;Bind();}
  protected void PageChanged(object sender,GridViewPageEventArgs e){gvPayments.PageIndex=e.NewPageIndex;Bind();}
 }
}
