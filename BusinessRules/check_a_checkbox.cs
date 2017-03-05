using System;
using P21.Extensions.BusinessRule;
namespace apc
{
    public class checkCheckbox : Rule
    {
        public override RuleResult Execute()
        {
            RuleResult result = new RuleResult();
            try
            {
                Data.Fields.GetFieldByAlias("Checkbox").FieldValue = "Y";

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
            return "checkCheckbox";
        }

        //requried class to provide a short description
        public override string GetDescription()
        {
            return "Check a checkbox";
        }
    }
}

