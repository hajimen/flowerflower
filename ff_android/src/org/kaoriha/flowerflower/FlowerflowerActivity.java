package org.kaoriha.flowerflower;

import android.os.Bundle;
import android.webkit.WebSettings;

import com.phonegap.DroidGap;

public class FlowerflowerActivity extends DroidGap {
//	private static final String TAG = "FlowerflowerActivity";
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        super.setBooleanProperty("keepRunning", false);
        super.loadUrl("file:///android_asset/www/flowerflower/index.html");
    }

    @Override
    public void init() {
    	super.init();
        WebSettings settings = this.appView.getSettings();
        settings.setSupportZoom(true);
        settings.setBuiltInZoomControls(true);
        appView.setVerticalFadingEdgeEnabled(true);
        appView.setVerticalScrollBarEnabled(true);
        appView.setVerticalScrollbarOverlay(true);
    }
}