package org.kaoriha.flowerflower.compile;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import net.arnx.jsonic.JSON;

import org.kaoriha.flowerflower.compile.document.Depot;
import org.kaoriha.flowerflower.compile.document.Fragment;
import org.kaoriha.flowerflower.compile.document.IndexEntry;

import junit.framework.Assert;
import junit.framework.TestCase;

public class DepotTest extends TestCase {
	public void testSerialize() throws IOException, ClassNotFoundException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(bos);

		Fragment f2 = new Fragment();
		f2.setHtml("test0");
		f2.setKey("10fe8509");
		f2.setNext(null);

		Fragment f = new Fragment();
		f.setHtml("test");
		f.setKey("30fe8509");
		f.setNext(f2);

		IndexEntry e = new IndexEntry();
		e.setName("test");
		e.setStartFragment(f);

		Depot d = new Depot();
		d.getFragmentSet().add(f);
		d.getFragmentSet().add(f2);
		d.getIndexEntryList().add(e);

		oos.writeObject(d);

		oos.close();
		bos.close();

		ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
		ObjectInputStream ois = new ObjectInputStream(bis);

		Depot nd = (Depot) ois.readObject();

		ois.close();
		bis.close();

		Assert.assertFalse(d == nd);
		Assert.assertTrue(d.equals(nd));

		Assert.assertEquals("{}", JSON.encode(nd.diff(d)));

		Fragment df = null;
		for (Fragment nf : nd.getFragmentSet()) {
			if (nf.equals(f)) {
				nf.setHtml("test2");
				df = nf;
			}
		}

		Assert.assertEquals("{\"h30fe8509\":\"test2\"}", JSON.encode(nd.diff(d)));

		IndexEntry e2 = new IndexEntry();
		e2.setName("test3");
		e2.setStartFragment(df);
		nd.getIndexEntryList().add(e2);

		Assert.assertEquals(
				"{\"h30fe8509\":\"test2\",\"INDEX_KEY\":[\"{\\\"start\\\":\\\"30fe8509\\\",\\\"name\\\":\\\"test\\\"}\",\"{\\\"start\\\":\\\"30fe8509\\\",\\\"name\\\":\\\"test3\\\"}\"]}",
				JSON.encode(nd.diff(d)));

		nd.getFragmentSet().remove(f2);
		nd.getIndexEntryList().remove(e2);
		Assert.assertEquals("{\"h10fe8509\":null,\"h30fe8509\":\"test2\",\"n10fe8509\":null}", JSON.encode(nd.diff(d)));
	}

	public void testDiffSame() {

	}

	// TODO hashCode縺ｮ繝�せ繝�
}
