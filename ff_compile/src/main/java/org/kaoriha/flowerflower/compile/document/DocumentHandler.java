package org.kaoriha.flowerflower.compile.document;

import com.googlecode.jatl.Html;

public abstract class DocumentHandler {
	abstract public void start();

	abstract public void end();

	abstract public Chronicle getChronicle();

	abstract public Html getHtml();

	abstract public PushMessageMap getPushMessageMap();
	
	abstract public Fragment getCurrentFragment();
}
