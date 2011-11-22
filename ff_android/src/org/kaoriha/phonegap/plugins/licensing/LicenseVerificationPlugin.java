package org.kaoriha.phonegap.plugins.licensing;

import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;
import com.phonegap.api.PluginResult.Status;
import org.json.JSONObject;
import org.kaoriha.phonegap.plugins.licensing.LicenseQuery;

public class LicenseVerificationPlugin extends Plugin {
	private static final String TAG = "LicenseVerificationPlugin";    

	//	Action to execute 
	public static final String ACTION = "query";

	/**
	 * 	Executes the request and returns PluginResult
	 * 
	 * 	@param action		Action to execute
	 * 	@param data			JSONArray of arguments to the plugin
	 *  @param callbackId	The callback id used when calling back into JavaScript
	 *  
	 *  @return				A PluginRequest object with some result
	 * */
	@Override
	public PluginResult execute(String action, JSONArray data, String callbackId) {
		LicenseServiceConnection conn = new LicenseServiceConnection(ctx);
		PluginResult result;
		if (ACTION.equals(action)) {
			try {
				String nonce = data.getString(0);
				PLicenseQuery q = new PLicenseQuery(Integer.parseInt(nonce), callbackId);
				conn.offer(q);
				result = new PluginResult(PluginResult.Status.NO_RESULT);
				result.setKeepCallback(true);
			} catch (JSONException e) {
				Log.w(TAG, "Got JSON Exception: " + e.getMessage());
				result = new PluginResult(Status.JSON_EXCEPTION);
			}
		} else {
			Log.w(TAG, "Invalid action : "+action+" passed");
			result = new PluginResult(Status.INVALID_ACTION);
		}
		
		Log.i(TAG, "execute OK");
		return result;
	}

	private class PLicenseQuery extends LicenseQuery {
		private final int nonce;
		private final String callbackId;

		PLicenseQuery(int nonce, String callbackId) {
			this.nonce = nonce;
			this.callbackId = callbackId;
		}

		@Override
		public void response(LicenseQuery.ResponseCode responseCode, String signedData,
				String signature) {
			try {
				buildResponse(responseCode, signedData, signature);
			} catch (JSONException e) {
				Log.w(TAG, "code error");
			}
		}

		private void buildResponse(LicenseQuery.ResponseCode responseCode, String signedData,
				String signature)  throws JSONException {
			JSONObject response = new JSONObject();
			response.put("responseCode", responseCode.name());
			Log.d(TAG, "responseCode: " + responseCode.name());
			response.put("signedData", signedData);
			Log.d(TAG, "signedData: " + signedData);
			response.put("signature", signature);
			Log.d(TAG, "signature: " + signature);
			success(new PluginResult(PluginResult.Status.OK, response), callbackId);
		}

		@Override
		public void missingPermissionError() {
			error("ERROR_MISSING_PERMISSION", callbackId);
		}

		@Override
		public void connectionError() {
			error("ERROR_CONNECTION", callbackId);
		}

		@Override
		public int getNonce() {
			return nonce;
		}
	}

}
