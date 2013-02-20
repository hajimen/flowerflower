package org.kaoriha.miyako;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class Span extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.Span span = (org.kaoriha.flowerflower._20130216.Span) target;
		doc.getHtml().span();
		if (span.getClazz() != null) {
			doc.getHtml().classAttr(span.getClazz());
		}
		if (span.getStyle() != null) {
			doc.getHtml().style(span.getStyle());
		}
		sp.process(span.getContent(), span);
		doc.getHtml().end();
	}

}
