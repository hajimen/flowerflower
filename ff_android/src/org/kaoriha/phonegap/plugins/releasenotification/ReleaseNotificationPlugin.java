package org.kaoriha.phonegap.plugins.releasenotification;

import org.json.JSONArray;
import org.json.JSONObject;

import android.util.Log;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;
import com.phonegap.api.PluginResult.Status;

public class ReleaseNotificationPlugin extends Plugin {
	private static final String TAG = "ReleaseNotificationPlugin";    

	private static enum Action {
		start,
		stop,
		updated,
		setToken,
		getToken,
		clear
	}
	
	/**
	 * 	Executes the request and returns PluginResult
	 * 
	 * 	@param action		Action to execute
	 * 	@param data			JSONArray of arguments to the plugin
	 *  @param callbackId	The callback id used when calling back into JavaScript
	 *  
	 *  @return				A PluginRequest object with a status
	 * */
	@Override
	public PluginResult execute(String action, JSONArray data, String callbackId) {
		PluginResult result = null;
		
		try {
			switch (Action.valueOf(action)) {
			case start:
			{
				String site = data.getString(0);
				String lastEtag = data.getString(1);
				String lastSid = data.getString(2);
				String title = data.getString(3);
				new Notifier(ctx).start(site, lastEtag, lastSid, title);
				break;
			}
			case stop:
			{
				new Notifier(ctx).stop();
				break;
			}
			case updated:
			{
				String etag = data.getString(0);
				String sid = data.getString(1);
				String toNextRelease = data.getString(2);
				new Notifier(ctx).updated(etag, sid, toNextRelease);
				break;
			}
			case setToken:
			{
				String token = data.getString(0);
				new Notifier(ctx).setToken(token);
				break;
			}
			case getToken:
			{
				String token = new Notifier(ctx).getToken();
				JSONObject j = new JSONObject();
				j.put("token", token);
				return new PluginResult(PluginResult.Status.OK, j);
			}
			case clear:
			{
				new Notifier(ctx).clear();
				break;
			}
			}
			result = new PluginResult(Status.OK);
		} catch (Exception e) {
			result = new PluginResult(Status.INVALID_ACTION);
			Log.d(TAG, "Invalid action: " + action);
		}

		return result;
	}

}
