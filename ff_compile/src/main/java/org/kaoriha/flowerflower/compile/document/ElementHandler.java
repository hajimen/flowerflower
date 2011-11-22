package org.kaoriha.flowerflower.compile.document;

import org.kaoriha.flowerflower.compile.SourceProcessor;

public abstract class ElementHandler<T extends DocumentHandler> {
	protected T doc;

	public void text(String text) {
		doc.getHtml().text(text);
	}

	public void setDocumentHandler(T doc) {
		this.doc = doc;
	}

	public abstract void handle(SourceProcessor sp, Object parent, Object target);
}
