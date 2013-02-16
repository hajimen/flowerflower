package org.kaoriha.flowerflower.compile;

import java.io.File;
import java.io.IOException;

import junit.framework.Assert;
import junit.framework.TestCase;
import net.arnx.jsonic.JSONException;

import org.joda.time.DateTime;

public class TimeTableTest extends TestCase {
	public void testLoadSave() throws JSONException, IOException {
		File f = new File("bin/tabletest.json");
		if (f.exists()) {
			f.delete();
		}

		TimeTable t = new TimeTable("bin/tabletest.json");
		t.add(DateTime.now(), "1234");
		t.save();
	}

	public void testGetSidDT() throws JSONException, IOException {
		TimeTable t = new TimeTable("bin/tabletest.json");
		t.getList().clear();
		DateTime dt1 = DateTime.now().minusDays(1);
		DateTime dt2 = dt1.plusDays(1);
		t.add(dt1, "1234");
		t.add(dt2, "5678");
		Assert.assertEquals(dt1, t.getDateTime("1234"));
		Assert.assertEquals(null, t.getDateTime("9012"));
	}
}
