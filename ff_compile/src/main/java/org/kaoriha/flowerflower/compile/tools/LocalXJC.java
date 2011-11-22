package org.kaoriha.flowerflower.compile.tools;

import java.util.ArrayList;
import java.util.List;

import com.sun.tools.internal.xjc.Driver;

public class LocalXJC {
	/**
	 * @param args
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		List<String> al = new ArrayList<String>();
		al.add("schema/flowerflower.xsd");
		al.add("-d");
		al.add("src/main/generated");
		Driver.main(al.toArray(new String[0]));
	}
}
