from selenium import webdriver
import time

class ChromeDriverMac():

    def test(self):
        # Instantiate Chrome Browser Command
        driver = webdriver.Chrome(executable_path="/Users/viki/Documents/chromedriver")
        # Open the provided URL
        driver.get("https://avengers.opexanalytics.com/")
        driver.implicitly_wait(30)

        emailid = driver.find_element_by_name("username")
        emailid.send_keys("opextestautomation@opexanalytics.com")

        passw = driver.find_element_by_name("password")
        passw.send_keys("Opex@123")
        time.sleep(2)

        submit = driver.find_element_by_id("kc-login")
        submit.click()
        time.sleep(2)

        # activeAppsCount
        activeapps = driver.find_element_by_xpath(".//span[contains(text(),'Active Apps')]/following-sibling::span")
        # activeapps = driver.find_element_by_xpath(".//span[contains(text(),'Inactive Apps')]/following-sibling::span")
        # activeapps = driver.find_element_by_xpath(".//span[contains(text(),'In Progress Apps')]/following-sibling::span")
        activeapps.click()
        time.sleep(10)

        for x in range(100):
         # actionMenu
         ellipsiss = driver.find_element_by_xpath(".//i[@class='more icon-v2-more']")
         ellipsiss.click()
         # time.sleep(2)

         delete = driver.find_element_by_xpath(".//div[contains(text(),'Delete')]")
         delete.click()
         # time.sleep(2)

         delete = driver.find_element_by_xpath(".//span[contains(text(),'Yes, delete it')]")
         # time.sleep(5)
         delete.click()
         time.sleep(3)
        time.sleep(3)

cc = ChromeDriverMac()
cc.test()