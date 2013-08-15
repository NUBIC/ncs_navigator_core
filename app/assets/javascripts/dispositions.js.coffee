# This comes straight from railscasts.com
# http://railscasts.com/episodes/88-dynamic-select-menus-revised
jQuery ->

  # get all select list options for event dispositions
  event_dispositions = $('#event_event_disposition').html()

  # on change filter the event dispositions to those in the
  # selected event category
  $('#event_event_disposition_category_code').change ->
    filter_event_dispositions(true)

  filter_event_dispositions = (add_blank) ->
    category = $('#event_event_disposition_category_code :selected').text()
    console.log(category)

    filter_text = event_filter_text(category)
    options = $(event_dispositions).filter(category_filter(category)).html()
    if options
      options_html = build_options_html(options, filter_text, add_blank)
      $('#event_event_disposition').html(options_html)
      if add_blank
        $("#event_event_disposition option[value='']").attr('selected', 'selected');
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
    filter = event_filter_text(category)
    optgroup_filter = "optgroup[label=\"#{filter}\"]"
    console.log(optgroup_filter)
    return optgroup_filter

  event_filter_text = (category) ->
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
    return filter

  # Similar to the DispositionMapper.determine_category_from_contact_type
  # method, this filter determines the disposition category based on the
  # contact type
  contact_mode_filter = (contact_type_val) ->
    filter = contact_filter_text(contact_type_val)
    optgroup_filter = "optgroup[label=\"#{filter}\"]"
    console.log(optgroup_filter)
    return optgroup_filter

  contact_filter_text = (contact_type_val) ->
    console.log("calling contact_filter_text")
    console.log(contact_type_val)
    switch(contact_type_val)
      when "PBS Participant Eligibility Screening"
        filter = "PBS Eligibility Screening"
      when "Pregnancy Screener"
        filter = "Pregnancy Screener Event"
      when "Provider Recruitment"
        filter = "Provider Recruitment"
      when "1","4","6"
        filter = "General Study Visit Event"
      when "2"
        filter = "Mailed Back SAQ Event"
      when "3","5"
        filter = "Telephone Interview Event"
      else
        filter = "General Study Visit Event"
    console.log(filter)
    return filter

  # get all select list options for contact dispositions
  contact_dispositions = $('#contact_contact_disposition').html()

  # on change filter the contact dispositions to those in the
  # selected contact mode
  $('#contact_contact_type_code').change ->
    filter_contact_dispositions(true)

  filter_contact_dispositions = (add_blank) ->
    contact_type_val = $('#contact_contact_type_code :selected').val()
    console.log(contact_type_val)

    # override disposition category filter if event type is a Screener event
    event_type = $('span#event_type').text().trim()
    console.log(event_type)
    if event_type == "PBS Participant Eligibility Screening" || event_type == "Pregnancy Screener"
      contact_type_val = event_type
    # provider recruitment check
    pr_event = $('h1#page_title').text().trim()
    if pr_event == 'Provider Recruitment Contact'
      contact_type_val = 'Provider Recruitment'

    filter_text = contact_filter_text(contact_type_val)
    options = $(contact_dispositions).filter(contact_mode_filter(contact_type_val)).html()
    if options
      options_html = build_options_html(options, filter_text, add_blank)
      $('#contact_contact_disposition').html(options_html)
      if add_blank
        $("#contact_contact_disposition option[value='']").attr('selected', 'selected');
    else
      $('#contact_contact_disposition').empty()

  build_options_html = (options, filter_text, add_blank) ->
    if add_blank
      options_html = "<optgroup label=\"" + filter_text + "\"><option value=\"\">-- Select Disposition --</\option>#{options}</\optgroup>"
    else
      options_html = "<optgroup label=\"" + filter_text + "\">#{options}<\optgroup>"
    return options_html

  filter_dispositions = ->
    # determine which page we are on
    if $('#event_event_disposition').length > 0
      filter_event_dispositions(false)
    if $('#contact_contact_disposition').length > 0
      filter_contact_dispositions(false)

  # on page load filter dispositions
  filter_dispositions()