$(document).ready(function() {
	$('#sales_listing_item_id').change(function() {
		window.location.search = "item_id=" + $(this).val();
	}); 
});
