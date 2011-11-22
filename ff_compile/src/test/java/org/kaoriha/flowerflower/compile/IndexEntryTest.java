package org.kaoriha.flowerflower.compile;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import org.kaoriha.flowerflower.compile.document.IndexEntry;

import junit.framework.Assert;
import junit.framework.TestCase;

public class IndexEntryTest extends TestCase {
	public void testSerialize() throws IOException, ClassNotFoundException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(bos);

		IndexEntry e = new IndexEntry();
		e.setName("test");
		oos.writeObject(e);
		
		oos.close();
		bos.close();
		
		ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
		ObjectInputStream ois = new ObjectInputStream(bis);
		
		IndexEntry ne = (IndexEntry) ois.readObject();
		
		ois.close();
		bis.close();
		
		Assert.assertFalse(e == ne);
		Assert.assertTrue(e.equals(ne));
	}

	// TODO hashCode縺ｮ繝�せ繝�
}
