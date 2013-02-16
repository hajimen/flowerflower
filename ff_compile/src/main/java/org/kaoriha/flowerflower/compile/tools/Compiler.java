package org.kaoriha.flowerflower.compile.tools;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import javax.xml.bind.JAXBException;

import org.joda.time.DateTime;
import org.joda.time.LocalTime;
import org.kaoriha.flowerflower.compile.Builder;
import org.kaoriha.flowerflower.compile.Constant;
import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.TimeTable;
import org.kaoriha.flowerflower.compile.document.Chronicle;
import org.xml.sax.SAXException;

public class Compiler {

	/**
	 * @param args
	 * @throws ClassNotFoundException 
	 * @throws JAXBException 
	 * @throws SAXException 
	 * @throws IOException 
	 */
/*
	public static void main(String[] args) throws JAXBException, ClassNotFoundException, SAXException, IOException {
		ArrayList<String> s = new ArrayList<String>(Arrays.asList(args));
		if (s.size() < 3) {
			System.out.println("Arguments: source.xml chronicle.bin timetable.json [lastReleasedSeparationId]");
			return;
		}
		String sourceFilename = s.get(0);
		s.remove(0);
		String chronicleFilename = s.get(0);
		s.remove(0);
		String timeTableFilename = s.get(0);
		s.remove(0);
		String lastReleasedSeparationId = null;
		DateTime startTime = null;
		if (Constant.TEST_RELEASE_PERIOD == null) {
			if (s.size() > 0) {
				lastReleasedSeparationId = s.get(0);
				s.remove(0);
			}
		} else {
			if (s.size() > 0) {
				startTime = LocalTime.parse(s.get(0)).toDateTimeToday();
				s.remove(0);
			} else {
				startTime = new DateTime().plusMinutes(2);
			}
		}

		SourceProcessor sp = new SourceProcessor("org.kaoriha.flowerflower._20111001");
		sp.parse(sourceFilename);
		sp.save(sourceFilename);

		// chronicleをマージ
		Chronicle mc;
		TimeTable tt = new TimeTable(timeTableFilename);
		if (Constant.TEST_RELEASE_PERIOD != null) {
			tt.getList().clear();
		}
		File chronicleFile = new File(chronicleFilename);
		if (chronicleFile.exists()) {
			Chronicle oldChronicle = Chronicle.load(chronicleFile);

			if (lastReleasedSeparationId == null) {
				DateTime dt = DateTime.now().plusHours(1);
				for (Map.Entry<DateTime, String> e: tt.getList()) {
					if (e.getKey().isBefore(dt)) {
						lastReleasedSeparationId = e.getValue();
					} else {
						break;
					}
				}
			}

			if (lastReleasedSeparationId == null) {
				mc = sp.getDocumentHandler().getChronicle();
				if (Constant.TEST_RELEASE_PERIOD == null) {
					Merger.prepareNewTimeTable(mc, tt);
				} else {
					Merger.prepareNewTestTimeTable(mc, tt, startTime);
				}
			} else {
				mc = Merger.run(sp.getDocumentHandler().getChronicle(), oldChronicle, tt, lastReleasedSeparationId);
			}
		} else {
			mc = sp.getDocumentHandler().getChronicle();
			if (Constant.TEST_RELEASE_PERIOD == null) {
				Merger.prepareNewTimeTable(mc, tt);
			} else {
				Merger.prepareNewTestTimeTable(mc, tt, startTime);
			}
		}
		tt.save();
		mc.save(chronicleFile);
		sp.getDocumentHandler().setChronicle(mc);

		// ビルド
		File d = new File("gen");
		if (d.exists()) {
			if (!d.isDirectory()) {
				throw new IllegalArgumentException("gen should be a directory.");
			}
		} else if (!d.mkdir()) {
			throw new IllegalArgumentException("cannot create gen directory.");
		}
		Builder b = new Builder(sp.getDocumentHandler(), tt, lastReleasedSeparationId, d);
		b.build();
	}
*/
}
