$('#new_parsed_auction')[0].reset()
$("#parsed_auctions_list").html("<%= escape_javascript( render(:partial => "parsed_auctions") ) %>")
$("#flash_messages").html("<%= escape_javascript(flash[:notice] = 'Successfully created parsed auctions.') %>")
