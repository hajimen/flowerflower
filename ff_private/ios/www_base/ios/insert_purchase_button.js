(function() {
	
function updatePrice() {
	window.Purchase.UpdatePrice ();
	$('#purchase_button').html(window.Purchase.Price);
}

$(document).ready(function() {
	$('#content').append('<p style="visibility:hidden">_</p><p style="visibility:hidden">_</p><p style="text-align:center">このタイトルを購入</p><a id="purchase_button" href="#" onClick="window.Purchase.Purchase();">---</a><p style="visibility:hidden">_</p><p style="visibility:hidden">_</p>');
});

document.addEventListener('deviceready', function() {
	updatePrice();
	setInterval(updatePrice, 1000);
}, false);

})();
