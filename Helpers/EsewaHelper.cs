using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
namespace LearningSystem.Helpers
{
    internal static class EsewaHelper
    {
        internal const string ResponseFields = "transaction_code,status,total_amount,transaction_uuid,product_code,signed_field_names";
        internal static string Setting(string name) { return ConfigurationManager.AppSettings[name] ?? ""; }
        internal static void Settings()
        {
            // This demo cannot be switched to production by changing just a config value.
            if (Setting("EsewaProductCode") != "EPAYTEST" || String.IsNullOrWhiteSpace(Setting("EsewaSecretKey"))
                || Setting("EsewaFormUrl") != "https://rc-epay.esewa.com.np/api/epay/main/v2/form"
                || Setting("EsewaStatusUrl") != "https://rc.esewa.com.np/api/epay/transaction/status/")
                throw new InvalidOperationException("Configure the eSewa sandbox settings locally before starting a test payment.");
            Uri origin;
            if (!Uri.TryCreate(Setting("HttpsOrigin"), UriKind.Absolute, out origin) || origin.Scheme != "https" || origin.UserInfo != "" || origin.Query != "" || origin.Fragment != "")
                throw new InvalidOperationException("A valid application HTTPS base URL is required.");
        }
        internal static string Sign(string message)
        {
            Settings();
            using (HMACSHA256 hmac = new HMACSHA256(Encoding.UTF8.GetBytes(Setting("EsewaSecretKey"))))
                return Convert.ToBase64String(hmac.ComputeHash(Encoding.UTF8.GetBytes(message)));
        }
        internal static string Value(Dictionary<string, object> data, string key)
        {
            object value;
            if (!data.TryGetValue(key, out value) || value == null) return "";
            if (!(value is string) && !(value is decimal) && !(value is int) && !(value is long)) throw new InvalidOperationException("Invalid payment response.");
            return Convert.ToString(value, CultureInfo.InvariantCulture);
        }
        internal static decimal Amount(Dictionary<string, object> data)
        {
            decimal amount;
            if (!Decimal.TryParse(Value(data, "total_amount"), NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out amount) || amount <= 0 || amount > 99999999.99m || Decimal.Round(amount,2)!=amount)
                throw new InvalidOperationException("Invalid payment amount.");
            return amount;
        }
        internal static Dictionary<string, object> VerifyResponse(string encoded)
        {
            Settings();
            if (String.IsNullOrEmpty(encoded) || encoded.Length > 12000) throw new InvalidOperationException("Missing or invalid payment response.");
            Dictionary<string, object> data;
            try
            {
                string json = new UTF8Encoding(false, true).GetString(Convert.FromBase64String(encoded));
                data = new JavaScriptSerializer { MaxJsonLength=12000, RecursionLimit=8 }.Deserialize<Dictionary<string,object>>(json);
            }
            catch (Exception ex) when (ex is FormatException || ex is ArgumentException || ex is InvalidOperationException)
            { throw new InvalidOperationException("The payment response could not be verified."); }
            if (data == null || Value(data,"signed_field_names") != ResponseFields) throw new InvalidOperationException("The payment signature fields are invalid.");
            StringBuilder message = new StringBuilder();
            foreach (string field in ResponseFields.Split(','))
            {
                string value = Value(data,field);
                if (String.IsNullOrEmpty(value)) throw new InvalidOperationException("The payment response is incomplete.");
                if (message.Length>0) message.Append(',');
                message.Append(field).Append('=').Append(value);
            }
            byte[] expected = Convert.FromBase64String(Sign(message.ToString()));
            byte[] received;
            try { received=Convert.FromBase64String(Value(data,"signature")); }
            catch (FormatException) { throw new InvalidOperationException("The payment signature is invalid."); }
            int difference=expected.Length ^ received.Length;
            for(int i=0;i<expected.Length;i++) difference |= expected[i] ^ (i<received.Length ? received[i] : 0);
            if(difference!=0 || Value(data,"product_code")!=Setting("EsewaProductCode") || Value(data,"status")!="COMPLETE")
                throw new InvalidOperationException("The payment response is not a verified success.");
            Amount(data);
            if(Value(data,"transaction_code").Length>100 || Value(data,"transaction_uuid").Length>64) throw new InvalidOperationException("Invalid payment reference.");
            return data;
        }
        internal static Dictionary<string,object> Status(DataRow payment)
        {
            Settings();
            string url=Setting("EsewaStatusUrl")+"?product_code="+HttpUtility.UrlEncode(Setting("EsewaProductCode"))
                +"&transaction_uuid="+HttpUtility.UrlEncode((string)payment["TransactionUUID"])
                +"&total_amount="+((decimal)payment["AmountNPR"]).ToString("0.00",CultureInfo.InvariantCulture);
            HttpWebRequest request=(HttpWebRequest)WebRequest.Create(url);
            request.Method="GET";request.Timeout=10000;request.ReadWriteTimeout=10000;request.AllowAutoRedirect=false;
            try
            {
                using(HttpWebResponse response=(HttpWebResponse)request.GetResponse())
                using(StreamReader reader=new StreamReader(response.GetResponseStream()))
                {
                    if(response.StatusCode!=HttpStatusCode.OK) throw new InvalidOperationException("Payment could not yet be verified. Please try later.");
                    char[] buffer=new char[16001];int count=reader.ReadBlock(buffer,0,buffer.Length);
                    if(count>16000) throw new InvalidOperationException("Invalid provider status response.");
                    Dictionary<string,object> data;
                    try { data=new JavaScriptSerializer {MaxJsonLength=16000,RecursionLimit=8}.Deserialize<Dictionary<string,object>>(new string(buffer,0,count)); }
                    catch (InvalidOperationException) { throw new InvalidOperationException("Invalid provider status response."); }
                    if(data==null || Value(data,"product_code")!=Setting("EsewaProductCode") || Value(data,"transaction_uuid")!=(string)payment["TransactionUUID"] || Amount(data)!=(decimal)payment["AmountNPR"])
                        throw new InvalidOperationException("Payment could not yet be verified. Please try later.");
                    if(Value(data,"ref_id").Length>100) throw new InvalidOperationException("Invalid provider reference.");
                    return data;
                }
            }
            catch(WebException) { throw new InvalidOperationException("Payment could not yet be verified because the sandbox is unavailable. Please try later."); }
            catch(ArgumentException) { throw new InvalidOperationException("Invalid provider status response."); }
            catch(IOException) { throw new InvalidOperationException("Payment could not yet be verified. Please try later."); }
        }
    }
}

