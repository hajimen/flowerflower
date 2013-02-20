package org.kaoriha.miyako;

import java.util.UUID;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;
import org.kaoriha.flowerflower.compile.document.Fragment;

public class Chapter extends ElementHandler<Document> {
	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.Chapter c = (org.kaoriha.flowerflower._20130216.Chapter) target;
		if (c.getSeparationId() == null) {
			c.setSeparationId(UUID.randomUUID().toString());
		}
		
		Fragment oldFragment = doc.getCurrentFragment();
		doc.newChapter(c.getName(), c.getSeparationId(), c.getPushMessage());
		if (oldFragment != null) {
			oldFragment.setHtml(oldFragment.getHtml() + "<p style=\"text-align:right;\"><a href=\"" + c.getSeparationId() + ".html\">" + c.getName() + "</a>につづく</p>");
		}
		doc.getHtml().h1().text(c.getName()).end();
	}
}
