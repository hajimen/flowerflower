package org.kaoriha.miyako;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

import com.googlecode.jatl.Html;
import com.googlecode.jatl.MarkupBuilder.TagClosingPolicy;

public class Rt extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.Rt rt = (org.kaoriha.flowerflower._20130216.Rt) target;
		Html html = doc.getHtml();
		html.start("rp", TagClosingPolicy.NORMAL).text("（").end();
		html.start("rt", TagClosingPolicy.NORMAL).text(rt.getContent()).end();
		html.start("rp", TagClosingPolicy.NORMAL).text("）").end();
	}

}
