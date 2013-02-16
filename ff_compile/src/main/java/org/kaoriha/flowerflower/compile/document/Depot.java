package org.kaoriha.flowerflower.compile.document;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
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
import org.kaoriha.flowerflower.compile.Constant;

import sun.reflect.generics.reflectiveObjects.NotImplementedException;

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

	private Object loadJson(String location, String name) throws IOException {
		if (location.startsWith("http:")) {
			throw new NotImplementedException();
		}
		
		File d = new File(location);
		if (!d.isDirectory()) {
			throw new IllegalArgumentException("not directory");
		}
		File catalogue = new File(d, name + ".json");
		if (!catalogue.canRead()) {
			throw new IllegalArgumentException(name + ".json not found");
		}

		FileInputStream fis = new FileInputStream(catalogue);
		Object o = JSON.decode(fis);
		fis.close();
		
		return o;
	}
	
	@SuppressWarnings("unchecked")
	public List<String> load(String location) throws IOException {
		Object o = loadJson(location, "catalogue");

		Map<String, Object> root = (Map<String, Object>) o;
		if (!root.containsKey("local")) {
			throw new IllegalArgumentException("catalogue.json is bad");
		}
		List<String> local = (List<String>) root.get("local");
		Map<String, String> express;
		if (root.containsKey("express")) {
			express = (Map<String, String>) root.get("express");
		} else {
			express = new HashMap<String, String>();
		}
		
		Map<String, String> depot = new HashMap<String, String>();
		String skipTo = null;
		for (String name : local) {
			if (skipTo != null) {
				if (name != skipTo) {
					continue;
				}
				skipTo = null;
			}
			Map<String, String> f;
			if (express.containsKey(name)) {
				skipTo = express.get(name);
				f = (Map<String, String>)loadJson(location, name + skipTo);
			} else {
				f = (Map<String, String>)loadJson(location, name);
			}
			depot.putAll(f);
		}

		fragmentSet.clear();
		indexEntryList.clear();
		List<Map<String, String>> index = JSON.decode(depot.get(org.kaoriha.flowerflower.compile.Constant.INDEX_KEY));
		for (Map<String, String> m : index) {
			IndexEntry ie = new IndexEntry();
			ie.setName(m.get("name"));
			String sfk = m.get("start");
			Fragment sf = loadFragmentSet(depot, sfk);
			ie.setStartFragment(sf);
			indexEntryList.add(ie);
		}
		loadFragmentSet(depot, Constant.ABOUT_THIS_APP_INITIAL_KEY);
		loadFragmentSet(depot, Constant.CHARACTER_NOTE_INITIAL_KEY);
		
		return local;
	}

	private Fragment loadFragmentSet(Map<String, String> depot, String sfk) {
		Fragment sf = new Fragment();
		sf.setHtml(depot.get("h" + sfk));
		sf.setKey(sfk);
		String k = sfk;
		Fragment f = sf;
		fragmentSet.add(f);
		while (depot.containsKey("n" + k) && depot.get("n" + k) != null) {
			k = depot.get("n" + k);
			Fragment nf = new Fragment();
			nf.setKey(k);
			nf.setHtml(depot.get("h" + k));
			f.setNext(nf);
			f = nf;
			fragmentSet.add(f);
		}
		return sf;
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
