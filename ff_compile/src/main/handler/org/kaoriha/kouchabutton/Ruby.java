package org.kaoriha.kouchabutton;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

import com.googlecode.jatl.MarkupBuilder.TagClosingPolicy;

public class Ruby extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.Ruby ruby = (org.kaoriha.flowerflower._20130216.Ruby) target;
		doc.getHtml().start("ruby", TagClosingPolicy.NORMAL);
		sp.process(ruby.getContent(), ruby);
		doc.getHtml().end();
	}

}
