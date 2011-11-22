package org.kaoriha.phonegap.plugins.releasenotification;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class Receiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context ctx, Intent intent) {
		new Notifier(ctx).poll();
	}
}
