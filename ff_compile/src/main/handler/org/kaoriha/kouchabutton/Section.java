package org.kaoriha.kouchabutton;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class Section extends ElementHandler<Document> {
	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
//		org.kaoriha.flowerflower._20111001.Section s = (org.kaoriha.flowerflower._20111001.Section) target;
		doc.getHtml().div().classAttr("in_nav").p().text("＊").end().end();
	}
}
