package org.kaoriha.flowerflower.compile;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

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

		Assert.assertEquals("{\"h10fe8509\":\"test0\",\"n30fe8509\":\"10fe8509\",\"n10fe8509\":null}", c
				.getDepot("SEP_2").diff(c.getDepot("SEP_1")));
	}
}
