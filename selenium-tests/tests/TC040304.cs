using System;
using System.Collections.Generic;

using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using selenium_tests;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Interactions.Internal;

namespace selenium_tests.tests
{
    [TestFixture]
    public class TC040304 : AbstractTestCase
    {
        [Test]
        public void Start_test1()
        {
            writeline_log("navigate sataturn.de");
            wd.Navigate().GoToUrl("https://www.saturn.de");
            writeline_log("click FAQ");
            wd.FindElement(OpenQA.Selenium.By.XPath("//*[contains(text(),'Hilfe & FAQ')]")).Click();
            writeline_log("check fake text 'go read manuals'");
            Assert.IsTrue(this.IsElementVisibleByText("go read manuals"));

        }

    }
}
