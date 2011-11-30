$('#<%= "parsed_auction_#{@parsed_auction[:id]}" %>')
  .fadeOut ->
    $(this).remove()
    $('<%= escape_javascript(render(:partial => "parsed_auctions"))%>')
.appendTo('#parsed_auctions_list')
  .hide()
  .fadeIn()