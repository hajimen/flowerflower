package org.kaoriha.flowerflower.compile;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.SortedSet;
import java.util.TreeSet;

import net.arnx.jsonic.JSON;
import net.arnx.jsonic.JSONException;

import org.apache.commons.lang3.tuple.Pair;
import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.ISODateTimeFormat;

public class TimeTable {
	
	private static DateTimeFormatter FMT = ISODateTimeFormat.dateTimeNoMillis();
	private SortedSet<Map.Entry<DateTime, String>> list = new TreeSet<Map.Entry<DateTime, String>>(new Comparator<Map.Entry<DateTime, String>>() {
		@Override
		public int compare(Entry<DateTime, String> l,
				Entry<DateTime, String> r) {
			return l.getKey().compareTo(r.getKey());
		}
	});
	private String filename;

	public TimeTable(String filename) throws JSONException, IOException {
		this.filename = filename;
		File f = new File(filename);
		if (f.canRead()) {
			FileInputStream fis = new FileInputStream(f);
			Object o = JSON.decode(fis);
			fis.close();

			@SuppressWarnings("unchecked")
			List<List<String>> ll = (List<List<String>>) o;
			for (List<String> l : ll) {
				DateTime dt = DateTime.parse(l.get(0), FMT);
				list.add(Pair.of(dt, l.get(1)));
			}
		}
	}

	public void save() throws IOException {
		List<List<String>> o = new ArrayList<List<String>>();
		for (Map.Entry<DateTime, String> e : list) {
			List<String> i = new ArrayList<String>();
			i.add(e.getKey().toString(FMT));
			i.add(e.getValue());
			o.add(i);
		}
		FileOutputStream fos = new FileOutputStream(filename);
		JSON.encode(o, fos, true);
		fos.close();
	}

	public DateTime getDateTime(String publicationId) {
		for (Map.Entry<DateTime, String> e : list) {
			if (e.getValue().equals(publicationId)) {
				return e.getKey();
			}
		}
		return null;
	}

	public SortedSet<Map.Entry<DateTime, String>> getList() {
		return Collections.unmodifiableSortedSet(list);
	}

	public void add(DateTime dt, String publicationId) {
		list.add(Pair.of(dt, publicationId));
	}

	public void remove(String publicationId) {
		for (Map.Entry<DateTime, String> e : list) {
			if (e.getValue().equals(publicationId)) {
				list.remove(e);
				return;
			}
		}
	}
}
