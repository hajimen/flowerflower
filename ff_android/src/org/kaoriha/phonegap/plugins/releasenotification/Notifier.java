package org.kaoriha.phonegap.plugins.releasenotification;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.kaoriha.flowerflower.FlowerflowerActivity;
import org.kaoriha.flowerflower.R;
import org.kaoriha.phonegap.plugins.licensing.LicenseQuery;
import org.kaoriha.phonegap.plugins.licensing.LicenseServiceConnection;

import android.app.ActivityManager;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.util.Log;

public class Notifier {
	private static final String TAG = "releasenotification.Notifier";    

	private static final int NOTIFICATION_ID = 1;

	static enum HttpHeader {
		AuthScheme("X-flowerflower-AuthScheme"),
		AuthToken("X-flowerflower-AuthToken"),
		ErrorReason("X-flowerflower-ErrorReason"),
		AuthStatus("X-flowerflower-AuthStatus");

		public final String val;
		private HttpHeader(String val) {
			this.val = val;
		}
	}
	private static final String AUTH_SCHEME = "Android_LVL";

	private static final String SPKEY_SITE = "site";
	private static final String SPKEY_LAST_SID = "lastSid";
	private static final String SPKEY_LAST_CATALOGUE_ETAG = "catalogueETag";
	private static final String SPKEY_TITLE = "title";
	private static final String SPKEY_FAIL_REPEAD = "failRepeat";
	private static final String SPKEY_TOKEN = "token";

	private static final String CATALOGUE_PATH = "Auth/catalogue.json";
	private static final String TO_NEXT_RELEASE_PATH = "tonextrelease.txt";
	private static final String CHALLENGE_PATH = "Office/AndroidLvl/RequestAuthChallenge.ashx";
	private static final String CHALLENGE_RESPONSE_PATH = "Office/AndroidLvl/RequestAuthToken.ashx";
	
	private static final long RESCHEDULE_AFTER_FAIL_1_SPAN = 30 * 1000;
	private static final int RESCHEDULE_AFTER_FAIL_1_REPEAT = 5;
	private static final long RESCHEDULE_AFTER_FAIL_2_SPAN = 5 * 60 * 1000;
	private static final int RESCHEDULE_AFTER_FAIL_2_REPEAT = 100;
	private static final long RESCHEDULE_AFTER_FAIL_3_SPAN = 24 * 60 * 60 * 1000;
	private static final long RESCHEDULE_NEXT_UNKNOWN_SPAN = 24 * 60 * 60 * 1000;
	private static final long RESCHEDULE_FOREGROUND = 60 * 1000; 
	private static final long RESCHEDULE_NOT_CONNECTED = 15 * 60 * 1000; 

	private static final String HTTP_HEADER_ETAG = "ETag";

	private static final String CATALOGUE_PUSH_MESSAGE_KEY = "push_message";

	private static LicenseServiceConnection LICENSE_SERVICE_CONNECTION = null;
	private static Object STATIC_SYNC = new Object();

	private final Context ctx;
	private final SharedPreferences pref;
	private String site;

	public Notifier(Context ctx) {
		this.ctx = ctx;
		pref = ctx.getSharedPreferences(getClass().getCanonicalName(), 0);
		site = pref.getString(SPKEY_SITE, null);
		
		synchronized(STATIC_SYNC) {
			if (LICENSE_SERVICE_CONNECTION == null) {
				LICENSE_SERVICE_CONNECTION = new LicenseServiceConnection(ctx.getApplicationContext());
			}
		}
	}

	public void start(String site, String lastEtag, String lastSid, String title) {
		pref.edit().putString(SPKEY_SITE, site)
				.putString(SPKEY_LAST_CATALOGUE_ETAG, lastEtag)
				.putString(SPKEY_LAST_SID, lastSid)
				.putString(SPKEY_TITLE, title).commit();
		this.site = site;

		ToNextReleasePolling tp = new ToNextReleasePolling();
		tp.poll();
		if (tp.isFailed) {
			Log.d(TAG, "ToNextReleasePolling failed");
			rescheduleAfterFail();
			return;
		}
		schedule(tp.toNextRelease);
	}

	public void stop() {
		AlarmManager am = (AlarmManager) ctx.getSystemService(Context.ALARM_SERVICE);
		Intent intent = new Intent(ctx, Receiver.class);
		PendingIntent pi = PendingIntent.getBroadcast(ctx, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
		am.cancel(pi);
	}

	public void updated(String etag, String sid, String toNextRelease) {
		clearFailRepeat();
		pref.edit().putString(SPKEY_LAST_CATALOGUE_ETAG, etag).putString(SPKEY_LAST_SID, sid).commit();
		schedule(Long.parseLong(toNextRelease));
	}

	public void clear() {
		pref.edit().clear().commit();
	}

	public void setToken(String token) {
		pref.edit().putString(SPKEY_TOKEN, token).commit();
	}

	public String getToken() {
		return pref.getString(SPKEY_TOKEN, null);
	}

	public void poll() {
		ConnectivityManager cm = (ConnectivityManager)ctx.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo ni = cm.getActiveNetworkInfo();
        if (ni == null || !ni.isConnected()) {
			Log.d(TAG, "poll() when not connected");
			schedule(RESCHEDULE_NOT_CONNECTED);
        	return;
        }

		try {
			if (new ForegroundCheckTask().execute(ctx).get()) {
				Log.d(TAG, "poll() when foreground");
				schedule(RESCHEDULE_FOREGROUND);
			} else {
				Log.d(TAG, "poll() when background");
				pollBackground();
			}
		} catch (Exception e) {
			Log.e(TAG, "poll() failed", e);
		}
	}

	private static class ForegroundCheckTask extends
			AsyncTask<Context, Void, Boolean> {

		@Override
		protected Boolean doInBackground(Context... params) {
			final Context context = params[0].getApplicationContext();
			return isAppOnForeground(context);
		}

		private boolean isAppOnForeground(Context context) {
			ActivityManager activityManager = (ActivityManager) context
					.getSystemService(Context.ACTIVITY_SERVICE);
			List<RunningAppProcessInfo> appProcesses = activityManager
					.getRunningAppProcesses();
			if (appProcesses == null) {
				return false;
			}
			final String packageName = context.getPackageName();
			for (RunningAppProcessInfo appProcess : appProcesses) {
				if (appProcess.importance == RunningAppProcessInfo.IMPORTANCE_FOREGROUND
						&& appProcess.processName.equals(packageName)) {
					return true;
				}
			}
			return false;
		}
	}

	private void updateToken() {
		Log.d(TAG, "updateToken()");
		Challenge c = new Challenge();
		c.get();
		if (c.isFailed) {
			Log.d(TAG, "auth challenge failed");
			return;
		}
		PLicenseQuery q = new PLicenseQuery(c.id, c.nonce);
		LICENSE_SERVICE_CONNECTION.offer(q);
	}

	private HttpResponse doGet(String url, String etag, boolean isAuth) throws ClientProtocolException, IOException {
		HttpGet method = new HttpGet(url);
		DefaultHttpClient client = new DefaultHttpClient();
		method.setHeader("Connection", "Keep-Alive");
		if (isAuth) {
			method.setHeader(HttpHeader.AuthScheme.val, AUTH_SCHEME);
			if (getToken() != null) {
				method.setHeader(HttpHeader.AuthToken.val, getToken());
			}
		}
		if (etag != null) {
			method.setHeader("If-None-Match", etag);
		}

		HttpResponse res = client.execute(method);
		
		if (isAuth && res.containsHeader(HttpHeader.AuthStatus.val)) {
			updateToken();
		}
		
		return res;
	}

	private void incrementFailRepeat() {
		int repeat = pref.getInt(SPKEY_FAIL_REPEAD, 0);
		pref.edit().putInt(SPKEY_FAIL_REPEAD, repeat + 1).commit();
	}

	private void clearFailRepeat() {
		pref.edit().remove(SPKEY_FAIL_REPEAD).commit();
	}

	private class PLicenseQuery extends LicenseQuery {
		long id;
		int nonce;

		PLicenseQuery(long id, int nonce) {
			this.id = id;
			this.nonce = nonce;
		}

		@Override
		public void response(ResponseCode responseCode, String signedData,
				String signature) {
			switch (responseCode) {
			case LICENSED:
			case LICENSED_OLD_KEY:
			case ERROR_NOT_MARKET_MANAGED:
			{
				ChallengeResponse cr = new ChallengeResponse(id, signedData, signature);
				cr.post();
				if (cr.isFailed) {
					Log.d(TAG, "PLicenseQuery ChallengeResponse failed");
					failed();
				} else {
					setToken(cr.token);
				}

				break;
			}
			default:
				Log.d(TAG, "PLicenseQuery bad response:" + responseCode.toString());
				break;
			}
		}

		@Override
		public void missingPermissionError() {
			Log.d(TAG, "PLicenseQuery.missingPermissionError()");
			failed();
		}

		@Override
		public void connectionError() {
			Log.d(TAG, "PLicenseQuery.connectionError()");
			failed();
		}

		@Override
		public int getNonce() {
			return nonce;
		}

		private void failed() {
			Log.d(TAG, "PLicenseQuery failed");
		}
	}

	private class ChallengeResponse {
		boolean isFailed;
		long id;
		String data;
		String signature;
		String token;
		
		ChallengeResponse(long id, String data, String signature) {
			this.id = id;
			this.data = data;
			this.signature = signature;
		}

		void post() {
			try {
				HttpPost method = new HttpPost(site + CHALLENGE_RESPONSE_PATH);
				DefaultHttpClient client = new DefaultHttpClient();
				method.setHeader("Connection", "Keep-Alive");
				method.setHeader(HttpHeader.AuthScheme.val, AUTH_SCHEME);
				if (getToken() != null) {
					method.setHeader(HttpHeader.AuthToken.val, getToken());
				}
				List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
				nameValuePairs.add(new BasicNameValuePair("id", Long.toString(id)));
				nameValuePairs.add(new BasicNameValuePair("data", data));
				nameValuePairs.add(new BasicNameValuePair("signature", signature));
				method.setEntity(new UrlEncodedFormEntity(nameValuePairs));
				Log.d(TAG, "ChallengeResponse id:" + id + " data:" + data + " signature:" + signature);

				HttpResponse r = client.execute(method);

				int s = r.getStatusLine().getStatusCode();
				if (s == HttpStatus.SC_OK) {
					Header h = r.getFirstHeader(HttpHeader.AuthToken.val);
					if (h == null) {
						isFailed = true;
					} else {
						isFailed = false;
						token = h.getValue();
					}
				} else {
					Header h2 = r.getFirstHeader(HttpHeader.ErrorReason.val);
					if (h2 != null) {
						Log.d(TAG, "ChallengeResponse post() failed. ErrorReason:" + h2.getValue());
					} else {
						Log.d(TAG, "ChallengeResponse post() failed. No ErrorReason");
					}
					isFailed = true;
				}
			} catch (Exception e) {
				Log.d(TAG, "ChallengeResponse post() failed", e);
				isFailed = true;
			}
		}
	}
	
	private class Challenge {
		boolean isFailed;
		long id;
		int nonce;
		
		void get() {
			try {
				HttpResponse r = doGet(site + CHALLENGE_PATH, null, false);
				int s = r.getStatusLine().getStatusCode();
				if (s == HttpStatus.SC_OK) {
					isFailed = false;
					String cs = EntityUtils.toString(r.getEntity(), "UTF-8");
					JSONObject j = new JSONObject(cs);
					nonce = j.getInt("nonce");
					id = j.getLong("id");
				} else {
					isFailed = true;
				}
			} catch (Exception e) {
				isFailed = true;
			}
		}
	}

	private class ToNextReleasePolling {
		boolean isFailed;
		long toNextRelease;

		void poll() {
			try {
				HttpResponse r = doGet(site + TO_NEXT_RELEASE_PATH, null, false);
				int s = r.getStatusLine().getStatusCode();
				if (s == HttpStatus.SC_OK) {
					isFailed = false;
					String cs = EntityUtils.toString(r.getEntity(), "UTF-8");
					toNextRelease = Long.parseLong(cs);
				} else {
					Log.d(TAG, "ToNextReleasePolling status:" + s);
					isFailed = true;
				}
			} catch (Exception e) {
				Log.d(TAG, "ToNextReleasePolling error", e);
				isFailed = true;
			}

		}
	}

	private class CataloguePolling {
		boolean isFailed;
		boolean isNew;
		JSONObject catalogue;
		String etag;

		void poll() {
			Log.d(TAG, "CataloguePolling.poll()");
			try {
				HttpResponse r = doGet(site + CATALOGUE_PATH,
						pref.getString(SPKEY_LAST_CATALOGUE_ETAG, null), true);
				int s = r.getStatusLine().getStatusCode();
				if (s == HttpStatus.SC_NOT_MODIFIED) {
					isFailed = false;
					isNew = false;
				} else if (s == HttpStatus.SC_OK) {
					isFailed = false;
					isNew = true;
					String cs = EntityUtils.toString(r.getEntity(), "UTF-8");
					catalogue = new JSONObject(cs);
					for (Header h : r.getAllHeaders()) {
						if (h.getName().equals(HTTP_HEADER_ETAG)) {
							etag = h.getValue();
							break;
						}
					}
				} else {
					isFailed = true;
				}
			} catch (Exception e) {
				isFailed = true;
			}
		}
	}

	private void pollBackground() {
		if (getToken() == null) {
			rescheduleAfterFail();
			return;
		}

		ToNextReleasePolling tp = new ToNextReleasePolling();
		tp.poll();
		if (tp.isFailed) {
			Log.d(TAG, "ToNextReleasePolling failed");
			rescheduleAfterFail();
			return;
		}

		CataloguePolling cp = new CataloguePolling();
		cp.poll();
		if (cp.isFailed) {
			Log.d(TAG, "CataloguePolling failed");
			rescheduleAfterFail();
			return;
		}
		if (!cp.isNew) {
			if (tp.toNextRelease == -1) {
				schedule(RESCHEDULE_NEXT_UNKNOWN_SPAN);
			} else {
				schedule(tp.toNextRelease);
			}
			Log.d(TAG, "CataloguePolling not new");
			return;
		}

		String pushMessage = null;
		if (cp.catalogue.has(CATALOGUE_PUSH_MESSAGE_KEY) ) {
			try {
				pushMessage = cp.catalogue.getString(CATALOGUE_PUSH_MESSAGE_KEY);
			} catch (JSONException e) {
				Log.i(TAG, "pollBackground()", e);
			}
		}

		String lastSid;
		try {
			lastSid = getLastSid(cp.catalogue);
			if (lastSid.equals(pref.getString(SPKEY_LAST_SID, null))) {
				schedule(tp.toNextRelease);
			}
		} catch (JSONException e) {
			Log.d(TAG, "bad JSON", e);
			rescheduleAfterFail();
			return;
		}

		if (pushMessage != null) {
			int icon = R.drawable.notification;
			Notification n = new Notification(icon, pushMessage, System.currentTimeMillis());
			n.flags = Notification.FLAG_AUTO_CANCEL;
			Intent i = new Intent(ctx, FlowerflowerActivity.class);
			i.setAction(Intent.ACTION_MAIN);
			i.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
	        PendingIntent pi = PendingIntent.getActivity(ctx, 0, i, 0);
	        n.setLatestEventInfo(ctx.getApplicationContext(), pref.getString(SPKEY_TITLE, null), pushMessage, pi);
	        NotificationManager nm = (NotificationManager) ctx.getSystemService(Context.NOTIFICATION_SERVICE);
	        nm.notify(NOTIFICATION_ID, n);
		}
        
        pref.edit().putString(SPKEY_LAST_SID, lastSid).putString(SPKEY_LAST_CATALOGUE_ETAG, cp.etag).commit();

        clearFailRepeat();
        
        schedule(tp.toNextRelease);

        Log.d(TAG, "pollBackground() success");
	}

	private String getLastSid(JSONObject catalogue) throws JSONException {
		JSONArray local = catalogue.getJSONArray("local");
		return local.getString(local.length() - 1);
	}

	private void rescheduleAfterFail() {
		long span;
		int repeat = pref.getInt(SPKEY_FAIL_REPEAD, 0);
		if (repeat < RESCHEDULE_AFTER_FAIL_1_REPEAT) {
			span = RESCHEDULE_AFTER_FAIL_1_SPAN;
		} else if (repeat < RESCHEDULE_AFTER_FAIL_2_REPEAT){
			span = RESCHEDULE_AFTER_FAIL_2_SPAN;
		} else {
			span = RESCHEDULE_AFTER_FAIL_3_SPAN;
		}
		schedule(span);
		incrementFailRepeat();
	}

	private void schedule(long after) {
		Intent intent = new Intent(ctx, Receiver.class);
		PendingIntent pi = PendingIntent.getBroadcast(ctx, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
		AlarmManager am = (AlarmManager) ctx.getSystemService(Context.ALARM_SERVICE);
		am.set(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + after, pi);
	}
}
