package org.kaoriha.flowerflower.compile;

import java.util.Date;

import it.sauronsoftware.cron4j.Predictor;
import junit.framework.TestCase;

public class Cron4jTest extends TestCase {
	public void testSimple() throws Exception {
		Date now = new Date();
		String pattern = "0 3 * jan-jun,sep-dec mon-fri";
		Predictor p = new Predictor(pattern, now);
		for (int i = 0; i < 10; i++) {
			System.out.println(p.nextMatchingDate());
		}
	}
}
