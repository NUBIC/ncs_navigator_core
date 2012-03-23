When /^I confirm the dialog$/ do
  page.driver.browser.switch_to.alert.accept
end

When /^I cancel the dialog$/ do
  page.driver.browser.switch_to.alert.dismiss
end
