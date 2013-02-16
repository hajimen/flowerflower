package org.kaoriha.flowerflower.compile.document;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.arnx.jsonic.JSON;

import org.apache.commons.httpclient.Cookie;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpState;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.cookie.CookiePolicy;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.kaoriha.flowerflower.compile.Constant;

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
	
	public List<String> load(String location, String cookieFilename, String authCode) throws IOException {
		Loader l = new Loader(location, cookieFilename, authCode);
		return l.load();
	}

	class Loader {
		private String location;
		private String cookieFilename;
		private String authCode;
		private boolean hasCookie = false;
        private HttpClient client = new HttpClient();

		public Loader(String location, String cookieFilename, String authCode) {
			this.location = location;
			this.cookieFilename = cookieFilename;
			this.authCode = authCode;

			File cf = new File(cookieFilename);
			if (cf.canRead()) {
				Cookie[] cookies = null;
				FileInputStream fis = null;
				ObjectInputStream ois = null; 
				try {
					fis = new FileInputStream(cf);
					ois = new ObjectInputStream(fis);
					cookies = (Cookie[]) ois.readObject();
				} catch (Exception e) {
					// noop
				} finally {
					IOUtils.closeQuietly(ois);
					IOUtils.closeQuietly(fis);
				}
				if (cookies != null) {
					HttpState initialState = new HttpState();
			        initialState.addCookies(cookies);
			        client.setState(initialState);
			        hasCookie = true;
				}
			}
	        client.getParams().setCookiePolicy(CookiePolicy.RFC_2109);
		}

		private void getAuthCookie() {
			if (authCode == null) {
				authCode = System.console().readLine("enter auth code:");
			}
	        PostMethod post = new PostMethod(location + Constant.RequestAuthCookie.PATH);
	        post.setFollowRedirects(false);
	        post.addParameter(Constant.RequestAuthCookie.AUTH_CODE_PARAM_NAME, authCode);
	        try {
	        	int result = client.executeMethod(post);
	        	String responseBody = post.getResponseBodyAsString();
	        	post.releaseConnection();
	        	if (result != HttpStatus.SC_OK || responseBody == null || !responseBody.equals("OK")) {
	        		System.err.println("bad auth code");
	        		System.exit(1);
	        	}
			} catch (Exception e) {
        		System.err.println("server error. " + e.getMessage());
        		System.exit(1);
			}
	        hasCookie = true;
		}

		private Object loadRemoteJson(String name) throws IOException {
			if (! hasCookie) {
				getAuthCookie();
			}

			GetMethod getMethod = new GetMethod(location + "Auth/" + name + ".json");
			getMethod.setFollowRedirects(false);
	        try {
	        	int result = client.executeMethod(getMethod);
	        	if (result != HttpStatus.SC_OK) {
	        		hasCookie = false;
					getMethod.releaseConnection();
	        		getAuthCookie();
	        		return loadRemoteJson(name);
	        	}
			} catch (Exception e) {
        		System.err.println("server error. " + e.getMessage());
        		System.exit(1);
			}

	        Object o = JSON.decode(getMethod.getResponseBodyAsStream());
			getMethod.releaseConnection();
			return o;
		}

		private Object loadJson(String name) throws IOException {
			if (location.startsWith("http:")) {
				return loadRemoteJson(name);
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
		public List<String> load() throws IOException {
			Object o = loadJson("catalogue");

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
					f = (Map<String, String>)loadJson(name + skipTo);
				} else {
					f = (Map<String, String>)loadJson(name);
				}
				depot.putAll(f);
			}
			if (location.startsWith("http:") && hasCookie) {
				FileOutputStream fos = null;
				ObjectOutputStream oos = null;
				try {
					fos = new FileOutputStream(cookieFilename);
					oos = new ObjectOutputStream(fos);
					oos.writeObject(client.getState().getCookies());
				} finally {
					IOUtils.closeQuietly(oos);
					IOUtils.closeQuietly(fos);
				}
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
