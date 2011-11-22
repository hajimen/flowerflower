package org.kaoriha.flowerflower.compile.document;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.arnx.jsonic.JSON;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;

public class Depot implements Serializable {
	private Set<Fragment> fragmentSet = new HashSet<Fragment>();
	private List<IndexEntry> indexEntryList = new ArrayList<IndexEntry>();

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public Fragment fromKey(String key) {
		for (Fragment f : fragmentSet) {
			if (f.getKey().equals(key)) {
				return f;
			}
		}
		return null;
	}

	public Map<String, Object> diff(Depot original) {
		Map<String, String> thisMap = new HashMap<String, String>();
		for (Fragment f : getFragmentSet()) {
			thisMap.putAll(f.toKV());
		}

		Map<String, String> origMap = new HashMap<String, String>();
		for (Fragment f : original.getFragmentSet()) {
			origMap.putAll(f.toKV());
		}

		Map<String, Object> diffMap = new HashMap<String, Object>();
		for (Map.Entry<String, String> e : origMap.entrySet()) {
			String k = e.getKey();
			if (!thisMap.containsKey(k)) {
				diffMap.put(k, null);
			}
		}
		for (Map.Entry<String, String> e : thisMap.entrySet()) {
			String k = e.getKey();
			String v = e.getValue();
			if (origMap.containsKey(k)) {
				if (!StringUtils.equals(origMap.get(k), v)) {
					diffMap.put(k, v);
				}
			} else {
				diffMap.put(k, v);
			}
		}

		List<Map<String, String>> thisIl = new ArrayList<Map<String, String>>();
		for (IndexEntry ie : getIndexEntryList()) {
			thisIl.add(ie.toKV());
		}
		List<Map<String, String>> origIl = new ArrayList<Map<String, String>>();
		for (IndexEntry ie : original.getIndexEntryList()) {
			origIl.add(ie.toKV());
		}
		if (!thisIl.equals(origIl)) {
			diffMap.put(Constant.INDEX_KEY, JSON.encode(thisIl));
		}

		return diffMap;
	}

	@Override
	public boolean equals(Object obj) {
		Depot d = (Depot) obj;
		return new EqualsBuilder().append(fragmentSet, d.fragmentSet)
				.append(indexEntryList, d.indexEntryList).isEquals();
	}

	@Override
	public int hashCode() {
		return new HashCodeBuilder().append(fragmentSet)
				.append(indexEntryList).toHashCode();
	}

	public Set<Fragment> getFragmentSet() {
		return fragmentSet;
	}

	public void setFragmentSet(Set<Fragment> fragmentSet) {
		this.fragmentSet = fragmentSet;
	}

	public List<IndexEntry> getIndexEntryList() {
		return indexEntryList;
	}

	public void setIndexElementList(List<IndexEntry> indexElementList) {
		this.indexEntryList = indexElementList;
	}
}
