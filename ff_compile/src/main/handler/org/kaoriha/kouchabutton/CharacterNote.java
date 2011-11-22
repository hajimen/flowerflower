package org.kaoriha.kouchabutton;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

public class CharacterNote extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20111001.CharacterNote cn = (org.kaoriha.flowerflower._20111001.CharacterNote) target;
		doc.startCharacterNote(cn.getName());
		doc.getHtml().h1().text(cn.getName()).end();
		sp.process(cn.getContent(), cn);
		doc.endCharacterNote();
	}
}
