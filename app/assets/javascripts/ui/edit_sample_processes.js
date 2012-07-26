$(function() {
  $('#id_btn').live('click',
  function() {
    var form = $(this).closest('form');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     dataType: 'script',
    
     success: function(response) {
       $("#process_tabs").children().each(function(){$(this).remove()})
       $("#displaying").children().each(function(){$(this).remove()})
       $("#process_tabs").append(response);
     }
    });
    return false;
  });
  
  // $('#date_btn').live('click', 
  // function() {
  //   var form = $(this).closest('form');
  //   $.ajax({
  //    type: $(form).attr('method'),
  //        url: $(form).attr('action'),
  //    data: $(form).serializeArray(),
  //    dataType: 'script',
  //   
  //    success: function(response) {
  //      console.log("----- search by date button????")
  //      // $(".display").html(response);
  //    }    
  // });
  // return false;
  // });
});