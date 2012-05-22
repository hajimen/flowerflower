package org.kaoriha.flowerflower.compile;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Map;

import org.kaoriha.flowerflower.compile.document.Chronicle;
import org.kaoriha.flowerflower.compile.document.Depot;
import org.kaoriha.flowerflower.compile.document.Fragment;
import org.kaoriha.flowerflower.compile.document.IndexEntry;

import junit.framework.Assert;
import junit.framework.TestCase;

public class ChronicleTest extends TestCase {
	public void testSerialize() throws IOException, ClassNotFoundException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(bos);

		Fragment f = new Fragment();
		f.setHtml("test");
		f.setKey("30fe8509");

		Fragment f2 = new Fragment();
		f2.setHtml("test0");
		f2.setKey("10fe8509");

		IndexEntry e = new IndexEntry();
		e.setName("test");
		e.setStartFragment(f);

		Depot d = new Depot();
		d.getFragmentSet().add(f);
		d.getIndexEntryList().add(e);

		Chronicle c = new Chronicle();
		c.snapshot("SEP_1", d);

		f.setNext(f2);
		d.getFragmentSet().add(f2);
		c.snapshot("SEP_2", d);

		oos.writeObject(c);

		oos.close();
		bos.close();

		ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
		ObjectInputStream ois = new ObjectInputStream(bis);

		Chronicle nc = (Chronicle) ois.readObject();

		ois.close();
		bis.close();

		Assert.assertFalse(c == nc);
		Assert.assertTrue(c.equals(nc));

		Map<String, Object> m = c.getDepot("SEP_2").diff(c.getDepot("SEP_1"));
		Assert.assertEquals("test0", m.get("h10fe8509"));
		Assert.assertEquals("10fe8509", m.get("n30fe8509"));
		Assert.assertEquals(null, m.get("n10fe8509"));
	}
}
