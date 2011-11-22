package org.kaoriha.flowerflower.compile.document;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;

public class IndexEntry implements java.io.Serializable, KVable {
	private String name;
	private Fragment startFragment;

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	public Map<String, String> toKV() {
		Map<String, String> map = new HashMap<String, String>();
		map.put("name", getName());
		map.put("start", getStartFragment().getKey());
		return map;
	}

	@Override
	public boolean equals(Object obj) {
		IndexEntry e = (IndexEntry) obj;
		return new EqualsBuilder().append(name, e.name)
				.append(startFragment, e.startFragment).isEquals();
	}

	@Override
	public int hashCode() {
		return new HashCodeBuilder().append(name).append(startFragment)
				.toHashCode();
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Fragment getStartFragment() {
		return startFragment;
	}

	public void setStartFragment(Fragment startFragment) {
		this.startFragment = startFragment;
	}
}
