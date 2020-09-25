from selenium import webdriver
import time


def test_setup():
    global driver
    driverLocation = "/Users/viki/Downloads/chromedriver"
    driver = webdriver.Chrome(driverLocation)
    driver.implicitly_wait(30)


def test_login():
    driver.get("https://training.opexanalytics.com/screening_app_yogesh/#/")

    emailid = driver.find_element_by_name("username")
    emailid.send_keys("Administrator")

    passw = driver.find_element_by_name("password")
    passw.send_keys("qzestqdqk*nV3mp")

    submmit = driver.find_element_by_xpath("/html/body/div[2]/div[1]/form/div[2]/div/button")
    submmit.click()


def test_verify():
    # scenario click
    driver.find_element_by_xpath("//*[@id='scenarios']/ng-include/div/div").click()
    time.sleep(3)
    assert 'https://training.opexanalytics.com/screening_app_yogesh/#/project/2/inputs' == driver.current_url

def test_verifyinp():
    # scenario click
    a = driver.find_element_by_xpath("//*[@id='tabs']/md-tabs/md-tabs-wrapper/md-tabs-canvas/md-pagination-wrapper/md-tab-item[1]")
    assert driver.find_element_by_xpath("//*[@id='tabs']/md-tabs/md-tabs-wrapper/md-tabs-canvas/md-pagination-wrapper/md-tab-item[1]") == a


def test_downloadinputs():
    # download inputs
    driver.find_element_by_xpath("//*[@id='tag_list']/div[2]/button[2]").click()


def test_dowbload():
    # download
    time.sleep(2)
    driver.find_element_by_xpath("//*[@id='bulk-download-modal']/footer/div/div/button[1]").click()


def test_teardown():
    time.sleep(5)
    driver.close()
    driver.quit()
