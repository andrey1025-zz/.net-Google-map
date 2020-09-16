using System;
using System.Xml;
using System.Net;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using Newtonsoft.Json;
using System.Web.Script.Serialization;
using System.Web.Script.Services;

namespace WebApplication1
{
    [WebService(Namespace = "http://tempuri.org/")]

    public partial class start : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HttpResponse.RemoveOutputCacheItem("/start.aspx");
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string getPlacesFromAPI(string lat, string lng)
        {
            HttpWebRequest request = CreateSOAPWebRequest("coordinates");

            XmlDocument SOAPReqBody = new XmlDocument();
            //SOAP Body Request  
            SOAPReqBody.LoadXml(
              @"<soap:Envelope xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
                  <soap:Body>
                    <get_list_of_points_by_coordinates xmlns=""http://tempuri.org/"">" +
                      "<lat>" + lat.ToString() + "</lat>" +
                      "<lon>" + lng.ToString() + "</lon>" +
                      "<precision>4</precision>" +
                    " </get_list_of_points_by_coordinates>" +
                  "</soap:Body>" +
                "</soap:Envelope>");

            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }
            //Geting response from request  
            string ServiceResult;
            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    //reading stream
                    ServiceResult = rd.ReadToEnd();
                    XmlDocument doc = new XmlDocument();
                    doc.LoadXml(ServiceResult);

                }
            }

            return ServiceResult;
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string getPlacesFromAPIByAddress(string address)
        {
            HttpWebRequest request = CreateSOAPWebRequest("address");

            XmlDocument SOAPReqBody = new XmlDocument();
            //SOAP Body Request  
            SOAPReqBody.LoadXml(
              @"<soap:Envelope xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
                  <soap:Body>
                    <get_list_of_points_by_address xmlns=""http://tempuri.org/"">" +
                      "<address>" + address.ToString() + "</address>" +
                    " </get_list_of_points_by_address>" +
                  "</soap:Body>" +
                "</soap:Envelope>");

            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }
            //Geting response from request  
            string ServiceResult;
            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    //reading stream
                    ServiceResult = rd.ReadToEnd();
                    XmlDocument doc = new XmlDocument();
                    doc.LoadXml(ServiceResult);

                }
            }

            return ServiceResult;
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string rebootDevice(string buildingID)
        {
            HttpWebRequest request = CreateSOAPWebRequest("reboot_device");

            XmlDocument SOAPReqBody = new XmlDocument();
            //SOAP Body Request  
            SOAPReqBody.LoadXml(
              @"<soap:Envelope xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
                  <soap:Body>
                    <reboot_device xmlns = ""http://tempuri.org/"">
                      <iid>" + buildingID.ToString() + "</iid>" +
                    "</reboot_device>" +
                  "</soap:Body>" +
               "</soap:Envelope>");

            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }
            //Geting response from request  
            string ServiceResult;
            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    //reading stream
                    ServiceResult = rd.ReadToEnd();
                    XmlDocument doc = new XmlDocument();
                    doc.LoadXml(ServiceResult);
                }
            }

            return ServiceResult;
        }
        public static HttpWebRequest CreateSOAPWebRequest(string type)
        {
            //Making Web Request  
            HttpWebRequest Req = (HttpWebRequest)WebRequest.Create(@"http://maps.ctstech.ca/api/service.asmx");
            //SOAPAction
            if(type.ToString() == "coordinates")
            {
                Req.Headers.Add(@"SOAPAction:http://tempuri.org/get_list_of_points_by_coordinates");
            }
            if(type.ToString() == "reboot_device")
            {
                Req.Headers.Add(@"SOAPAction:http://tempuri.org/reboot_device");
            }
            if (type.ToString() == "address")
            {
                Req.Headers.Add(@"SOAPAction:http://tempuri.org/get_list_of_points_by_address");
            }
            //Content_type
            Req.ContentType = "text/xml;charset=\"utf-8\"";
            Req.Accept = "text/xml";
            //HTTP method  
            Req.Method = "POST";
            //return HttpWebRequest  
            return Req;
        }

    }
}