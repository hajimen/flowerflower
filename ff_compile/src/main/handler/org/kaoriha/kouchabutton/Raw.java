package org.kaoriha.kouchabutton;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class Raw extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20111001.Raw raw = (org.kaoriha.flowerflower._20111001.Raw) target;
		if (raw.getContent() != null) {
			doc.getHtml().raw(raw.getContent());
		}
	}

}
