(function() {
window.Purchase = {};
window.Purchase.Price = "---";

function updatePrice() {
	cordova.exec(function(p) { window.Purchase.Price = p; }, null, "org.kaoriha.phonegap.plugins.purchase",
			"price", []);
}
window.Purchase.UpdatePrice = updatePrice;

function buy() {
	cordova.exec(null, null, "org.kaoriha.phonegap.plugins.purchase",
			"purchase", []);
}
window.Purchase.Purchase = buy;

})();
