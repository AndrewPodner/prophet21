using System;
using System.Text;
using P21.Extensions.BusinessRule;
using System.Windows.Forms;

namespace apc
{
    public class noOrderDateInThePast : Rule
    {
        public override RuleResult Execute()
        {
            RuleResult result = new RuleResult();
            try
            {
                DateTime OrderDate = Convert.ToDateTime(Data.Fields.GetFieldByAlias("order_date").FieldValue);
                if (OrderDate < System.DateTime.Today.AddDays(-1))
                {
                    MessageBox.Show("Order Date Cannot Be More Than 1 day in the past");
                    Data.Fields.GetFieldByAlias("order_date").FieldValue = Convert.ToString(System.DateTime.Today);
                }
            }
            catch (Exception ex)
            {
                result.Message = ex.Message;
            }
            result.Success = true;
            return result;
        }

        //required class to give a name to the class
        public override string GetName()
        {
            return "noOrderDateInThePast";
        }

        //requried class to provide a short description
        public override string GetDescription()
        {
            return "Assures that the order date cannot be set into the past";
        }
    }
}
