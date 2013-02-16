package org.kaoriha.kouchabutton;

import java.util.ArrayList;
import java.util.List;

import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.document.ElementHandler;

import com.googlecode.jatl.Html;

public class Text extends ElementHandler<Document> {

	@Override
	public void handle(SourceProcessor sp, Object parent, Object target) {
		org.kaoriha.flowerflower._20130216.Text text = (org.kaoriha.flowerflower._20130216.Text) target;
		if (text.getContent().size() == 0) {
			// 空要素
			return;
		}
		Html html = doc.getHtml();
		List<List<Object>> lineList = new ArrayList<List<Object>>();
		List<Object> currentLine = new ArrayList<Object>();
		lineList.add(currentLine);
		for (Object o : text.getContent()) {
			if (o instanceof String) {
				// 先頭と末尾の単独改行を取り除く
				String c = (String) o;
				if (c.length() == 0) {
					continue;
				}
				if (c.charAt(0) == '\n') {
					c = c.substring(1);
					if (c.length() == 0) {
						continue;
					}
				}
				if (c.charAt(c.length() - 1) == '\n') {
					c = c.substring(0, c.length() - 1);
					if (c.length() == 0) {
						currentLine = new ArrayList<Object>();
						lineList.add(currentLine);
						continue;
					}
				}

				String[] lines = c.split("\n");
				currentLine.add(lines[0]);
				if (lines.length == 1) {
					continue;
				}
				for (int i = 1; i < lines.length; i ++) {
					String line = lines[i];
					currentLine = new ArrayList<Object>();
					lineList.add(currentLine);
					if (line.length() > 0) {
						currentLine.add(line);
					}
				}
			} else {
				currentLine.add(o);
			}
		}

		for (List<Object> o : lineList) {
			html.p();
			if (o.size() == 0) {
				html.classAttr(Css.BLANK_LINE).text("_");
			} else {
				sp.process(o, text);
			}
			html.end();
		}
	}

}
