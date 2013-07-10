# This comes straight from railscasts.com
# http://railscasts.com/episodes/88-dynamic-select-menus-revised
jQuery ->
  dispositions = $('#event_event_disposition').html()
  console.log(dispositions)

  $('#event_event_disposition_category_code').change ->
    filter_dispositions()

  filter_dispositions = ->
    category = $('#event_event_disposition_category_code :selected').text()
    console.log(category)

    options = $(dispositions).filter(category_filter(category)).html()
    console.log(options)
    if options
      $('#event_event_disposition').html(options)
    else
      $('#event_event_disposition').empty()

  # Due to the disconnect between the code list for Event
  # Disposition Category (EVENT_DSPSTN_CAT_CL1) and the
  # category label text in the disposition code lists in the
  # .xsd we need to map the code list text to the category
  # group text.
  #
  # WARNING: if the .xsd or Disposition Category text changes
  #          in MDES versions this will need to be updated
  category_filter = (category) ->
    switch(category)
      when "General Study Visits (including CASI SAQs)"
        filter = "General Study Visit Event"
      when "Household Enumeration Events"
        filter = "Household Enumeration Event"
      when "Internet Survey Events"
        filter = "Internet Survey Event"
      when "Mailed Back Self Administered Questionnaires"
        filter = "Mailed Back SAQ Event"
      when "PBS Eligibility Screening"
        filter = "PBS Eligibility Screening"
      when "Pregnancy Screening Events"
        filter = "Pregnancy Screener Event"
      when "Provider Based Recruitment"
        filter = "Provider Recruitment"
      when "Telephone Interview Events"
        filter = "Telephone Interview Event"
      else
        filter = category

    optgroup_filter = "optgroup[label=\"#{filter}\"]"
    console.log(optgroup_filter)
    return optgroup_filter


  # on page load filter dispositions
  filter_dispositions()