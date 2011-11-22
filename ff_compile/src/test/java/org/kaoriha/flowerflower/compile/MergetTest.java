package org.kaoriha.flowerflower.compile;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

import net.arnx.jsonic.JSONException;

import org.joda.time.DateTime;
import org.kaoriha.flowerflower.compile.document.Chronicle;
import org.kaoriha.flowerflower.compile.document.Depot;
import org.kaoriha.flowerflower.compile.document.Fragment;
import org.kaoriha.flowerflower.compile.document.IndexEntry;

import junit.framework.Assert;
import junit.framework.TestCase;

public class MergetTest extends TestCase {
	public void testUsual() throws JSONException, IOException {
		Fragment f = new Fragment();
		f.setHtml("test1");
		f.setKey("30fe8509");

		Fragment f2 = new Fragment();
		f2.setHtml("test2");
		f2.setKey("10fe8509");
		f2.setNext(null);
		f.setNext(f2);

		IndexEntry e = new IndexEntry();
		e.setName("test");
		e.setStartFragment(f);

		Depot d = new Depot();
		d.getFragmentSet().add(f);
		d.getFragmentSet().add(f2);
		d.getIndexEntryList().add(e);

		Chronicle c = new Chronicle();
		c.snapshot("10fe8509", d);

		Chronicle nc = new Chronicle();
		nc.snapshot("10fe8509", d);

		Fragment f3 = new Fragment();
		f3.setHtml("test3");
		f3.setKey("40fe8509");
		f3.setNext(null);
		f2.setNext(f3);
		d.getFragmentSet().add(f3);

		c.snapshot("40fe8509", d);

		f.setHtml("test1.1");
		f2.setHtml("test2.1");
		f3.setHtml("test3.1");

		nc.snapshot("40fe8509", d);

		TimeTable tt = new TimeTable("nofile");
		DateTime dt = DateTime.now().toLocalDate().toDateTime(Constant.RELEASE_TIME);
		tt.getMap().put(dt.minusDays(2), "30fe8509");
		tt.getMap().put(dt.minusDays(1), "10fe8509");
		tt.getMap().put(dt, "40fe8509");

		Chronicle mc = Merger.run(nc, c, tt, "10fe8509");

		int ch = 0;
		for (Chronicle.Entry ce : mc.getEntryList()) {
			Set<Fragment> fs = ce.getDepot().getFragmentSet();
			for (Fragment lf : fs) {
				if (lf.getKey().equals("10fe8509")) {
					String h = lf.getHtml();
					if (ch == 0) {
						Assert.assertEquals("test2", h);
						ch ++;
					} else {
						Assert.assertEquals("test2.1", h);
					}
					break;
				}
			}
		}

		ch = 0;
		for (Map.Entry<DateTime, String> tte : tt.getMap().entrySet()) {
			Assert.assertEquals(dt.minusDays(2 - ch), tte.getKey());
			ch ++;
		}
	}
}
