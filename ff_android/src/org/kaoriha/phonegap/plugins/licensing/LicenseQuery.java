package org.kaoriha.phonegap.plugins.licensing;

public abstract class LicenseQuery {
	public abstract void response(ResponseCode responseCode, String signedData,
			String signature);

	public abstract void missingPermissionError();

	public abstract void connectionError();

	public abstract int getNonce();

	public final void response(int responseCode, String signedData,
			String signature) {
		response(ResponseCode.valueOf(responseCode), signedData, signature);
	}

	public enum ResponseCode {
		LICENSED(0x0), NOT_LICENSED(0x1), LICENSED_OLD_KEY(0x2), ERROR_NOT_MARKET_MANAGED(
				0x3), ERROR_SERVER_FAILURE(0x4), ERROR_OVER_QUOTA(0x5),

		ERROR_CONTACTING_SERVER(0x101), ERROR_INVALID_PACKAGE_NAME(0x102), ERROR_NON_MATCHING_UID(
				0x103);

		private final int v;

		ResponseCode(int v) {
			this.v = v;
		}

		public static ResponseCode valueOf(int v)
				throws IllegalArgumentException {
			for (ResponseCode c : values()) {
				if (c.v == v) {
					return c;
				}
			}
			throw new IllegalArgumentException("bad responsecode value: " + v);
		}
	};
}
