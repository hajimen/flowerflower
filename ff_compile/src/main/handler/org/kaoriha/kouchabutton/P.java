package org.kaoriha.kouchabutton;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class P extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20111001.P p = (org.kaoriha.flowerflower._20111001.P) target;
		if (p.getContent().size() == 1) {
			Object o = p.getContent().get(0);
			if (o instanceof String && ((String) o).length() == 0) {
				doc.getHtml().p().classid(Css.BLANK_LINE).end();
				return;
			}
		}
		doc.getHtml().p();
		sp.process(p.getContent(), p);
		doc.getHtml().end();
	}

}
