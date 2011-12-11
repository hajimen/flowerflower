package org.kaoriha.kouchabutton;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringWriter;

import org.apache.commons.codec.digest.DigestUtils;
import org.kaoriha.flowerflower.compile.Constant;
import org.kaoriha.flowerflower.compile.document.Chronicle;
import org.kaoriha.flowerflower.compile.document.Depot;
import org.kaoriha.flowerflower.compile.document.DocumentHandler;
import org.kaoriha.flowerflower.compile.document.Fragment;
import org.kaoriha.flowerflower.compile.document.IndexEntry;
import org.kaoriha.flowerflower.compile.document.PushMessageMap;

import com.googlecode.jatl.Html;

public class Document extends DocumentHandler {
	private Chronicle chronicle = new Chronicle();
	private Depot depot = new Depot();
	private Fragment currentFragment = null;
	private StringWriter sw;
	private Html html;
	private Fragment currentCNFragment = null;
	private StringWriter cnSw;
	private Html cnHtml;
	private boolean isCharacterNote = false;
	private PushMessageMap pushMessageMap = new PushMessageMap();

	@Override
	public Chronicle getChronicle() {
		return chronicle;
	}

	@Override
	public void start() {
		Fragment cnf = depot.fromKey(Constant.CHARACTER_NOTE_INITIAL_KEY);
		if (cnf == null) {
			cnf = new Fragment();
			cnf.setHtml("");
			cnf.setKey(Constant.CHARACTER_NOTE_INITIAL_KEY);
		}
		depot.getFragmentSet().add(cnf);

		Fragment cnf2 = depot.fromKey(Constant.ABOUT_THIS_APP_INITIAL_KEY);
		if (cnf2 == null) {
			cnf2 = new Fragment();
			File f = new File(Constant.ABOUT_THIS_APP_FILENAME);
			try {
				if (f.canRead()) {
					FileInputStream fis = new FileInputStream(f);
					InputStreamReader isr = new InputStreamReader(fis, "UTF-8");
					BufferedReader br = new BufferedReader(isr);

					StringBuilder sb = new StringBuilder();
					String s;
					while ((s = br.readLine()) != null) {
						sb.append(s);
					}
					cnf2.setHtml(sb.toString());

					br.close();
					isr.close();
					fis.close();
				}
			} catch (IOException e) {
				System.out.println("ABOUT_THIS_APP_FILENAME file not found or bad.");
				cnf2.setHtml("");
			}
			cnf2.setKey(Constant.ABOUT_THIS_APP_INITIAL_KEY);
		}
		depot.getFragmentSet().add(cnf2);
	}

	@Override
	public void end() {
		lastSeparation();
	}

	public void newChapter(String name, String separationId, String pushMessage) {
		if (currentFragment != null) {
			lastSeparation();
		}
		newSeparation(separationId, pushMessage);

		IndexEntry ie = new IndexEntry();
		ie.setName(name);
		ie.setStartFragment(currentFragment);
		depot.getIndexEntryList().add(ie);
	}

	public void newSeparation(String separationId, String pushMessage) {
		pushMessageMap.put(separationId, pushMessage);
		Fragment f = new Fragment();
		f.setKey(separationId);
		if (currentFragment != null) {
			currentFragment.setHtml(sw.getBuffer().toString());
			depot.getFragmentSet().add(currentFragment);
			chronicle.snapshot(currentFragment.getKey(), depot);
			currentFragment.setNext(f);
		}
		currentFragment = f;
		sw = new StringWriter();
		html = new Html(sw);
	}

	private void lastSeparation() {
		currentFragment.setHtml(sw.getBuffer().toString());
		depot.getFragmentSet().add(currentFragment);
		chronicle.snapshot(currentFragment.getKey(), depot);
		currentFragment = null;
	}

	public Depot getDepot() {
		return depot;
	}

	@Override
	public Html getHtml() {
		if (isCharacterNote) {
			return cnHtml;
		} else {
			return html;
		}
	}

	public void startCharacterNote(String name) {
		if (isCharacterNote) {
			throw new IllegalStateException("startCharacterNode called twice.");
		}
		isCharacterNote = true;

		String key = DigestUtils.md5Hex(name);
		currentCNFragment = null;
		Fragment lf = null;
		for (Fragment f = depot.fromKey(Constant.CHARACTER_NOTE_INITIAL_KEY); f != null; f = f.getNext()) {
			lf = f;
			if (f.getKey().equals(key)) {
				currentCNFragment = f;
				break;
			}
		}
		if (currentCNFragment == null) {
			currentCNFragment = new Fragment();
			currentCNFragment.setKey(key);
			if (lf != null) {
				lf.setNext(currentCNFragment);
			}
		}
		cnSw = new StringWriter();
		cnHtml = new Html(cnSw);
	}

	public void endCharacterNote() {
		currentCNFragment.setHtml(cnSw.getBuffer().toString());
		depot.getFragmentSet().add(currentCNFragment);
		currentCNFragment = null;
		isCharacterNote = false;
	}

	@Override
	public PushMessageMap getPushMessageMap() {
		return pushMessageMap;
	}

	@Override
	public Fragment getCurrentFragment() {
		if (isCharacterNote) {
			return currentCNFragment;
		} else {
			return currentFragment;
		}
	}
}
