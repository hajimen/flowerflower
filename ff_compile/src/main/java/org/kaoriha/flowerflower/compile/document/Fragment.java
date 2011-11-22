package org.kaoriha.flowerflower.compile.document;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;

public class Fragment implements Serializable, KVable {
	private String key;
	private Fragment next;
	private String html;

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	public Map<String, String> toKV() {
		Map<String, String> map = new HashMap<String, String>();
		map.put("n" + key, getNextKeyIfExist());
		map.put("h" + key, getHtml());
		return map;
	}

	@Override
	public boolean equals(Object obj) {
		Fragment f = (Fragment) obj;
		return new EqualsBuilder().append(key, f.key)
				.append(getNextKeyIfExist(), f.getNextKeyIfExist())
				.append(html, f.html).isEquals();
	}

	@Override
	public int hashCode() {
		return new HashCodeBuilder().append(key).append(getNextKeyIfExist())
				.append(html).toHashCode();
	}

	public String getNextKeyIfExist() {
		if (next == null) {
			return null;
		}
		return next.getKey();
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public Fragment getNext() {
		return next;
	}

	public void setNext(Fragment next) {
		this.next = next;
	}

	public String getHtml() {
		return html;
	}

	public void setHtml(String html) {
		this.html = html;
	}
}
