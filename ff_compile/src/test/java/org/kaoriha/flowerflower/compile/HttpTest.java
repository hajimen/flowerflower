package org.kaoriha.flowerflower.compile;

import java.io.IOException;

import org.apache.commons.httpclient.Cookie;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpState;
import org.apache.commons.httpclient.cookie.CookiePolicy;
import org.apache.commons.httpclient.methods.GetMethod;

import junit.framework.TestCase;

public class HttpTest extends TestCase {
	public void testSimple() throws HttpException, IOException {
		String strURL = "http://kaoriha.org/kanzenhitogata/Office/Author/test.txt";

		// Get initial state object
        HttpState initialState = new HttpState();
        
        // Initial set of cookies can be retrieved from persistent storage 
        // and re-created, using a persistence mechanism of choice,
        Cookie mycookie = new Cookie(".foobar.com", "mycookie", "stuff", 
                "/", null, false);
        
        // and then added to your HTTP state instance
        initialState.addCookie(mycookie);
        
        // Get HTTP client instance
        HttpClient httpclient = new HttpClient();
        httpclient.getHttpConnectionManager().
                getParams().setConnectionTimeout(30000);
        httpclient.setState(initialState);
        
        // RFC 2101 cookie management spec is used per default
        // to parse, validate, format & match cookies
        httpclient.getParams().setCookiePolicy(CookiePolicy.RFC_2109);
        
        // A different cookie management spec can be selected
        // when desired
        
        //httpclient.getParams().setCookiePolicy(CookiePolicy.NETSCAPE);
        // Netscape Cookie Draft spec is provided for completeness
        // You would hardly want to use this spec in real life situations
        // httppclient.getParams().setCookiePolicy(
        //   CookiePolicy.BROWSER_COMPATIBILITY);
        // Compatibility policy is provided in order to mimic cookie
        // management of popular web browsers that is in some areas
        // not 100% standards compliant
        
        // Get HTTP GET method
        GetMethod httpget = new GetMethod(strURL);
        
        // Execute HTTP GET
        int result = httpclient.executeMethod(httpget);
        
        // Display status code
        System.out.println("Response status code: " + result);
        
        String body = httpget.getResponseBodyAsString();
        System.out.println("body: " + body);
        
        // Get all the cookies
        Cookie[] cookies = httpclient.getState().getCookies();
        
        // Display the cookies
        System.out.println("Present cookies: ");
        for (int i = 0; i < cookies.length; i++) {
            System.out.println(" - " + cookies[i].toString());
        }
        
        // Release current connection to the connection pool 
        // once you are done
        httpget.releaseConnection();

	}
}
