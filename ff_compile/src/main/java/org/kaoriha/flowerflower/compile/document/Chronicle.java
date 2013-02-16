package org.kaoriha.flowerflower.compile.document;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;

public class Chronicle {
	private Map<String, Depot> map = new HashMap<String, Depot>();

	private void put(String publicationId, Depot depot) {
		map.put(publicationId, depot);
	}

	public void snapshot(String separationId, Depot depot) {
		try {
			snapshotImpl(separationId, depot);
		} catch (IOException e) {
			// never
		} catch (ClassNotFoundException e) {
			// never
		}
	}

	private void snapshotImpl(String separationId, Depot depot)
			throws IOException, ClassNotFoundException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(bos);

		oos.writeObject(depot);

		oos.close();
		bos.close();

		ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
		ObjectInputStream ois = new ObjectInputStream(bis);

		Depot newDepot = (Depot) ois.readObject();

		ois.close();
		bis.close();

		put(separationId, newDepot);
	}

	@Override
	public boolean equals(Object obj) {
		Chronicle c = (Chronicle) obj;
		return new EqualsBuilder().append(map, c.map).isEquals();
	}

	@Override
	public int hashCode() {
		return new HashCodeBuilder().append(map).toHashCode();
	}

	public Depot getDepot(String separationId) {
		return map.get(separationId);
	}
}
