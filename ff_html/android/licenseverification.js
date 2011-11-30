/**
 *  
 *	Constructor
 */
var LicenseVerification = function() { 
}

/**
 * @param verificationResponse Normal response handler function of the verification service
 *        function verificationResponse(responseCode, signedData, signature) 
 * @param verificationError Error handler function of the verification service
 *        function verificationError(errorType) errorType: ERROR_MISSING_PERMISSION, ERROR_CONNECTION
 * @param nonce for digital signing
 *
 * verificationResponse(response): response is JSON object.
 * response.responseCode: string (digit number)
 * response.signedData: string
 * response.signature: string
 * 
 * verificationError(errorType): errorType is string.
 * errorType: ERROR_MISSING_PERMISSION, ERROR_CONNECTION
 */
LicenseVerification.prototype.query = function(verificationResponse, verificationError, nonce) {
    return PhoneGap.exec(verificationResponse, verificationError, 'LicenseVerification',	'query', [nonce]);
};

/**
 * 	Load LicenseVerification
 */

PhoneGap.addConstructor(function() {
	PhoneGap.addPlugin('licenseVerification', new LicenseVerification());
});
