package org.kaoriha.miyako;

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
				if (lines[0].length() > 0) {
					currentLine.add(lines[0]);
				}
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

		for (int i = 0; i < lineList.size(); i ++) {
			List<Object> line = lineList.get(i);
			if (line.size() == 0) {
				if (i < lineList.size() - 2) {
					List<Object> o2 = lineList.get(i + 1);
					List<Object> o3 = lineList.get(i + 2);
					if (o3.size() == 0 && o2.size() == 1 && o2.get(0) instanceof String) {
						String s2 = (String) o2.get(0);
						if (s2.matches("\t*＊")) {
							html.div().classAttr("in_nav").p().text("＊").end().end();
							i += 2;
							continue;
						}
					}
				}

				html.p();
				html.classAttr(Css.BLANK_LINE).text("_");
				html.end();
			} else {
				html.p();
				sp.process(line, text);
				html.end();
			}
		}
	}

}
