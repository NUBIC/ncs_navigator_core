$ -> 
  $('#contact_information_tab .toggle_contacts').hide()
  $('#contact_information_tab a#toggle_contacts').click ->
    txt = $.trim($('#contact_information_tab a#toggle_contacts').text())
    $('#contact_information_tab a#toggle_contacts').text(if txt == "Show Highest Ranked" then "Show All" else "Show Highest Ranked")
    $('#contact_information_tab .toggle_contacts').toggle()
