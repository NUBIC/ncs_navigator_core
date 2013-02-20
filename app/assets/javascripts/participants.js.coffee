$ -> 
  $('#contact_information_tab .extended_contacts').hide()
  $('#contact_information_tab a#toggle_contacts').click ->
    txt = $.trim($('#contact_information_tab a#toggle_contacts').text())
    $('#contact_information_tab a#toggle_contacts').text(if txt == "Show All" then "Show Highest Ranked" else "Show All")
    $('#contact_information_tab .extended_contacts').toggle()
