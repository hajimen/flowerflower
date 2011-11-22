package org.kaoriha.flowerflower.compile;

import java.io.*;
import java.util.Map;
import java.util.UUID;

import org.kaoriha.flowerflower.compile.document.Fragment;

import junit.framework.Assert;
import junit.framework.TestCase;

public class FragmentTest extends TestCase {
	public void testSerialize() throws IOException, ClassNotFoundException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(bos);
		
		Fragment f = new Fragment();
		f.setHtml("test");
		f.setKey(UUID.randomUUID().toString());
		f.setNext(f);
		oos.writeObject(f);
		
		oos.close();
		bos.close();
		
		ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
		ObjectInputStream ois = new ObjectInputStream(bis);
		
		Fragment nf = (Fragment) ois.readObject();
		
		ois.close();
		bis.close();
		
		Assert.assertFalse(f == nf);
		Assert.assertTrue(f.equals(nf));
	}
	
	public void testKV() {
		Fragment f = new Fragment();
		f.setHtml("test");
		f.setKey("1234");
		f.setNext(f);
		
		Map<String, String> m = f.toKV();
		for (Map.Entry<String, String> e : m.entrySet()) {
			if (e.getKey().equals("h1234")) {
				Assert.assertEquals("test", e.getValue());
			} else if (e.getKey().equals("n1234")) {
				Assert.assertEquals("1234", e.getValue());
			} else {
				Assert.fail("never");
			}
		}
	}
	// TODO hashCodeのテスト
}
