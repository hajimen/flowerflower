package org.kaoriha.flowerflower.compile;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import net.arnx.jsonic.JSON;
import net.arnx.jsonic.JSONException;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.ISODateTimeFormat;

public class TimeTable {
	private static DateTimeFormatter FMT = ISODateTimeFormat.dateTimeNoMillis();
	private TreeMap<DateTime, String> map = new TreeMap<DateTime, String>();
	private String filename;

	public TimeTable(String filename) throws JSONException, IOException {
		this.filename = filename;
		File f = new File(filename);
		if (f.canRead()) {
			FileInputStream fis = new FileInputStream(f);
			Object o = JSON.decode(fis);
			fis.close();

			@SuppressWarnings("unchecked")
			Map<String, String> fm = (Map<String, String>) o;
			for (Map.Entry<String, String> e : fm.entrySet()) {
				DateTime dt = DateTime.parse(e.getKey(), FMT);
				map.put(dt, e.getValue());
			}
		}
	}

	public TreeMap<DateTime, String> getMap() {
		return map;
	}

	public void save() throws IOException {
		Map<String, String> fm = new HashMap<String, String>();
		for (Map.Entry<DateTime, String> e : map.entrySet()) {
			fm.put(e.getKey().toString(FMT), e.getValue());
		}
		FileOutputStream fos = new FileOutputStream(filename);
		JSON.encode(fm, fos, true);
		fos.close();
	}

	public DateTime getDateTime(String separationId) {
		for (Map.Entry<DateTime, String> e : map.entrySet()) {
			if (e.getValue().equals(separationId)) {
				return e.getKey();
			}
		}
		return null;
	}
}
