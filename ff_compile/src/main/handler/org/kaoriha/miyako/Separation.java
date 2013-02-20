package org.kaoriha.miyako;

import java.util.UUID;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class Separation extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.Separation s = (org.kaoriha.flowerflower._20130216.Separation) target;
		if (s.getId() == null) {
			s.setId(UUID.randomUUID().toString());
		}
		doc.getHtml().hr();
		doc.newSeparation(s.getId(), s.getPushMessage());
	}
}
