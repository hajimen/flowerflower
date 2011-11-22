package org.kaoriha.flowerflower.compile;

import junit.framework.TestCase;
import com.googlecode.jatl.*;
import java.io.StringWriter;

public class JatlTest extends TestCase {
	public void testIt() {
		StringWriter sw = new StringWriter();

		Html html = new Html(sw);

		html.div().select().id("adam").name("adam").option("Hello", "1", true)
				.option("Crap", "2", false).br().endAll();
		String result = sw.getBuffer().toString();
		String expected = "\n" + "<div>\n"
				+ "	<select id=\"adam\" name=\"adam\">\n"
				+ "		<option value=\"1\" selected=\"selected\">Hello\n"
				+ "		</option>\n" + "		<option value=\"2\">Crap\n"
				+ "		</option>\n" + "		<br/>\n" + "	</select>\n" + "</div>";
		assertEquals(expected, result);
	}
}
