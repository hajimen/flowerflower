package org.kaoriha.kouchabutton;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class Div extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20111001.Div div = (org.kaoriha.flowerflower._20111001.Div) target;
		doc.getHtml().div();
		if (div.getClazz() != null) {
			doc.getHtml().classAttr(div.getClazz());
		}
		if (div.getStyle() != null) {
			doc.getHtml().style(div.getStyle());
		}
		sp.process(div.getContent(), div);
		doc.getHtml().end();
	}

}
