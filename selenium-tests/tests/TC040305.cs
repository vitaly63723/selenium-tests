using System;
using System.Collections.Generic;

using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using  selenium_tests;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Interactions.Internal;

namespace selenium_tests.tests
{
    [TestFixture]
    public class TC040305: AbstractTestCase
    {
        [Test]
        public void Start_test2()
        {
            logFileFolder = TestContext.Parameters["outputdir"];

            writeline_log("navigate sataturn.de");
            wd.Navigate().GoToUrl("https://www.saturn.de");
            writeline_log("zum warewnkorb click");
            wd.FindElement(OpenQA.Selenium.By.XPath("//*[contains(text(),'Zum Warenkorb')]")).Click();
            writeline_log("check einzelpreis");

            Assert.IsTrue(this.IsElementVisibleByText("Einzelpreis"));
        }     

    }
}
