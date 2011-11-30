$('#<%= "parsed_auction_#{@parsed_auction[:id]}" %>')
  .fadeOut ->
    $(this).remove()
$("#flash_messages").html("<%= escape_javascript(flash[:notice] = 'Successfully deleted parsed auctions.') %>")