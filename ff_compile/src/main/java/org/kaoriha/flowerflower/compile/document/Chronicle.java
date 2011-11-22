package org.kaoriha.flowerflower.compile.document;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;

public class Chronicle implements Serializable {
	public static class Entry implements Serializable {
		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;

		private String separationId;
		private Depot depot;

		public Entry(String separationId, Depot depot) {
			this.separationId = separationId;
			this.depot = depot;
		}
		public Depot getDepot() {
			return depot;
		}
		public String getSeparationId() {
			return separationId;
		}

		@Override
		public boolean equals(Object obj) {
			Entry e = (Entry) obj;
			return new EqualsBuilder().append(separationId, e.separationId).append(depot, e.depot).isEquals();
		}

		@Override
		public int hashCode() {
			return new HashCodeBuilder().append(separationId).append(depot).toHashCode();
		}
	}

	private List<Entry> list = new ArrayList<Entry>();
	private void put(String separationId, Depot depot) {
		list.add(new Entry(separationId, depot));
	}

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public void save(File file) throws IOException {
		FileOutputStream fos = new FileOutputStream(file);
		ObjectOutputStream oos = new ObjectOutputStream(fos);
		oos.writeObject(this);
		oos.close();
		fos.close();
	}

	public static Chronicle load(File file) throws IOException, ClassNotFoundException {
		FileInputStream fis = new FileInputStream(file);
		ObjectInputStream ois = new ObjectInputStream(fis);
		Chronicle c = (Chronicle) ois.readObject();
		ois.close();
		fis.close();
		return c;
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
		return new EqualsBuilder().append(list, c.list).isEquals();
	}

	@Override
	public int hashCode() {
		return new HashCodeBuilder().append(list).toHashCode();
	}

	public Depot getDepot(String separationId) {
		for (Entry e : list) {
			if (e.getSeparationId().equals(separationId)) {
				return e.getDepot();
			}
		}
		return null;
	}

	public List<Entry> getEntryList() {
		return list;
	}
}
