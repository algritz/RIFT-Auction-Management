$('#new_parsed_auction')[0].reset()
$('<%= escape_javascript(render(:partial => "parsed_auctions"))%>')
.appendTo('#parsed_auctions_list')
  .hide()
  .fadeIn()