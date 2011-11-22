package org.kaoriha.phonegap.plugins.licensing;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Set;

import com.android.vending.licensing.ILicenseResultListener;
import com.android.vending.licensing.ILicensingService;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

public class LicenseServiceConnection implements ServiceConnection {
	private static final String TAG = "LicenseServiceConnection";
	// Timeout value (in milliseconds) for calls to service.
	private static final int TIMEOUT_MS = 10 * 1000;

	private final Set<LicenseQuery> querySetInProgress = new HashSet<LicenseQuery>();
	private final Queue<LicenseQuery> pendingQueryQueue = new LinkedList<LicenseQuery>();
	private final Context context;
	private Handler handler;
	private ILicensingService service;

	public synchronized void onServiceConnected(ComponentName name,
			IBinder binder) {
		service = ILicensingService.Stub.asInterface(binder);
		processQueue();
		Log.i(TAG, "Service connected.");
	}

	public synchronized void onServiceDisconnected(ComponentName name) {
		// Called when the connection with the service has been
		// unexpectedly disconnected. That is, Market crashed.
		// If there are any checks in progress, the timeouts will handle them.
		Log.w(TAG, "Service unexpectedly disconnected.");
		service = null;
	}

	public LicenseServiceConnection(Context context) {
		this.context = context;
		HandlerThread handlerThread = new HandlerThread("background thread");
		handlerThread.start();
		this.handler = new Handler(handlerThread.getLooper());
	}

	private String getPackageName() {
		return context.getPackageName();
	}

	public synchronized void offer(LicenseQuery query) {
		if (service == null) {
			Log.i(TAG, "Binding to licensing service.");
			try {
				boolean bindResult = context.bindService(new Intent(
						ILicensingService.class.getName()), this, // ServiceConnection.
						Context.BIND_AUTO_CREATE);

				Log.i(TAG, "Binding OK");

				if (bindResult) {
					pendingQueryQueue.offer(query);
				} else {
					Log.e(TAG, "Could not bind to service.");
					query.connectionError();
				}
			} catch (SecurityException e) {
				query.missingPermissionError();
			} catch (Throwable e) {
				Log.e(TAG, "code error", e);
				query.connectionError();
			}
		} else {
			pendingQueryQueue.offer(query);
			processQueue();
		}
	}

	private void processQueue() {
		LicenseQuery query;
		while ((query = pendingQueryQueue.poll()) != null) {
			try {
				Log.i(TAG, "Calling checkLicense on service for "
						+ getPackageName());
				service.checkLicense(query.getNonce(), getPackageName(),
						new ResultListener(query));
				Log.i(TAG, "checkLicense OK");
				querySetInProgress.add(query);
			} catch (RemoteException e) {
				Log.w(TAG, "RemoteException in checkLicense call.", e);
				query.connectionError();
			}
		}
	}

	private class ResultListener extends ILicenseResultListener.Stub {
		private final LicenseQuery query;
		private Runnable onTimeout;

		public ResultListener(LicenseQuery q) {
			this.query = q;
			this.onTimeout = new Runnable() {
				public void run() {
					Log.i(TAG, "Check timed out.");
					query.connectionError();
					finishCheck(query);
				}
			};
			startTimeout();
		}

		// Runs in IPC thread pool. Post it to the Handler, so we can guarantee
		// either this or the timeout runs.
		public void verifyLicense(final int responseCode,
				final String signedData, final String signature) {
			handler.post(new Runnable() {
				public void run() {
					Log.i(TAG, "Received response.");
					// Make sure it hasn't already timed out.
					if (querySetInProgress.contains(query)) {
						clearTimeout();
						query.response(responseCode, signedData, signature);
						finishCheck(query);
					}
				}
			});
		}

		private void startTimeout() {
			Log.i(TAG, "Start monitoring timeout.");
			handler.postDelayed(onTimeout, TIMEOUT_MS);
		}

		private void clearTimeout() {
			Log.i(TAG, "Clearing timeout.");
			handler.removeCallbacks(onTimeout);
		}
	}

	private synchronized void finishCheck(LicenseQuery query) {
		querySetInProgress.remove(query);
		if (querySetInProgress.isEmpty()) {
			cleanupService();
		}
	}

	/** Unbinds service if necessary and removes reference to it. */
	private void cleanupService() {
		if (service != null) {
			try {
				context.unbindService(this);
			} catch (IllegalArgumentException e) {
				// Somehow we've already been unbound. This is a non-fatal
				// error.
				Log.e(TAG,
						"Unable to unbind from licensing service (already unbound)");
			}
			service = null;
		}
	}

	/**
	 * Inform the library that the context is about to be destroyed, so that any
	 * open connections can be cleaned up.
	 * <p>
	 * Failure to call this method can result in a crash under certain
	 * circumstances, such as during screen rotation if an Activity requests the
	 * license check or when the user exits the application.
	 */
	public synchronized void onDestroy() {
		cleanupService();
		handler.getLooper().quit();
	}
}
