$(document).ready(function() {
	setInterval(function() {
		if(document.getElementById("#jobs").style.display != "none") {
			window.location = '/parsed_auctions';
		}
	}, 30000);
});
