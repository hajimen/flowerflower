document.write("<script src='../jquery-1.6.2.min.js'></script>"
		+ "<script src='../design/spin.min.js'></script>");
var userAgent = navigator.userAgent.toLowerCase();
if (userAgent.match(/android/)) {
	document.write("<script src='../android/phonegap-1.1.0.js'></script>"
			+ "<script src='../android/licenseverification.js'></script>"
			+ "<script src='../android/releasenotification.js'></script>"
//			+ "<script src='../flowerflower/web.js'></script>"
			+ "<script src='../flowerflower/android_lvl.js'></script>"
			);
} else {
	document.write("<script src='../ios/cordova.ios.js'></script>"
			+ "<script src='../ios/scaleChanger.js'></script>"
			+ "<script src='../ios/purchase.js'></script>"
			+ "<script src='../flowerflower/ios_iap.js'></script>"
//			+ "<script src='../flowerflower/web.js'></script>"
			);
}
document.write("<script src='../flowerflower/common.js'></script>"
		+ "<script src='../design/design.js'></script>"
		+ "<script src='../tsume/tsume.js'></script>"
		+ "<script src='../flowerflower/site_constant.js'></script>"
		+ "<script src='../android/ruby_fix.js'></script>"
		);
