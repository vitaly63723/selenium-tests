using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using Newtonsoft.Json.Linq;


namespace selenium_tests
{
    [TestFixture]
    public abstract class AbstractTestCase
    {
        protected IWebDriver wd;
        private static string StartFolder = (System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase) + "\\").Substring(6);

        private const string configName = "aqua-config-powershell.json";

        
        public string logFileName = "selenium-test-log.txt";
        private string aquaRpojectConfigFile = "";
        
        public string logFilePath = "";



        [SetUp]
        public void TestSetup()
        {
            aquaRpojectConfigFile = StartFolder + configName;


            if (File.Exists(aquaRpojectConfigFile))
            {              
              logFilePath = Get_ps_parameter("outputdir") + logFileName;




            }
            else
            {
                throw new Exception("please check powershell git checkout setup script: no config data:" + aquaRpojectConfigFile);
            }



            wd = Create_Driver();


        }


        public IWebDriver Create_Driver()
        {
            int timeout = 10;

            var Chrome_options = new ChromeOptions();
            Chrome_options.AddArgument("no-sandbox");

            wd = new ChromeDriver(Chrome_options);
            wd.Manage().Timeouts().ImplicitWait = (TimeSpan.FromSeconds(timeout));
            wd.Manage().Timeouts().AsynchronousJavaScript = (TimeSpan.FromSeconds(timeout));
            wd.Manage().Timeouts().PageLoad = (TimeSpan.FromSeconds(timeout));
            wd.Manage().Window.Maximize();

            return wd;
        }

        [TearDown]
        public void TestTearDown()
        {
            wd.Quit();
        }


        /// <summary>
        /// checks if text is present on the display
        /// </summary>
        /// <param name="text"></param>
        /// <returns></returns>
        public bool IsElementVisibleByText(string text)
        {
            bool ElementIsVisible = false;
            try
            {
                //  string xpath = "//*[contains(.,'" + text + "')]";
                //  string xpath = "//*[normalize-space()='"+text+"']";
                string xpath = "//*[contains(normalize-space(),'" + text + "') or @value='" + text + "']";

                IWebElement elm = wd.FindElement(By.XPath(xpath));
                ElementIsVisible = true;
            }
            catch (NoSuchElementException)
            {

                ElementIsVisible = false;
            }
            return ElementIsVisible;
        }

        public void writeline_log(string txt)
        {
     
            using (StreamWriter sw = File.AppendText(logFilePath))
            {
                sw.WriteLine(txt);
            }
        }



        //public static string get_path(string user, string attr)
        //{

        //    string myJsonString = File.ReadAllText(StartFolder+"aqua-ps-config.json");
        //    var jo = JObject.Parse(myJsonString);
        //    var attrVal = jo[user][attr].ToString();
        //    return attrVal;
        //}


        public string Get_ps_parameter(string name)
        {

            string myJsonString = File.ReadAllText(aquaRpojectConfigFile);

            //ed string myJso
            var jo = JObject.Parse(myJsonString);
            var attrVal = jo[name].ToString();


            if (File.Exists(attrVal)) Console.WriteLine("");
            return attrVal;
        }


    }


}
