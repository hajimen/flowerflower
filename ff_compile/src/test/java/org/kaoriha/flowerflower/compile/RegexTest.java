package org.kaoriha.flowerflower.compile;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import junit.framework.TestCase;

public class RegexTest extends TestCase {
	public void testSimple() {
		Pattern p = Pattern.compile("^\n?([\\s\\S]*)\n?$");
		Matcher m = p.matcher("\n\nabc\n\n");
		String r = m.replaceFirst("$1");
		System.out.println(r);
		System.out.println(r.length());


	}
}
