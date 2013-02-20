package org.kaoriha.miyako;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class Root extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.Root r = (org.kaoriha.flowerflower._20130216.Root) target;
		sp.process(r.getTextOrChapterOrSection(), r);
	}

}
