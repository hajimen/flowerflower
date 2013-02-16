package org.kaoriha.kouchabutton;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class CharacterNote extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.CharacterNote cn = (org.kaoriha.flowerflower._20130216.CharacterNote) target;
		if (cn.getContent() == null || cn.getContent().size() == 0) {
			doc.removeCharacterNote(cn.getName());
			return;
		}
		if (cn.getContent().size() == 1) {
			Object o = cn.getContent().get(0);
			if (o instanceof String && ((String) o).trim().length() == 0) {
				doc.removeCharacterNote(cn.getName());
				return;
			}
		}
		doc.startCharacterNote(cn.getName());
		doc.getHtml().h1().text(cn.getName()).end();
		sp.process(cn.getContent(), cn);
		doc.endCharacterNote();
	}
}
