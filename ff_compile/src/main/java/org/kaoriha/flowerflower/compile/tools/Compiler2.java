package org.kaoriha.flowerflower.compile.tools;

import it.sauronsoftware.cron4j.Predictor;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import javax.xml.bind.JAXBException;

import org.joda.time.DateTime;
import org.kaoriha.flowerflower.compile.Builder;
import org.kaoriha.flowerflower.compile.Constant;
import org.kaoriha.flowerflower.compile.SourceProcessor;
import org.kaoriha.flowerflower.compile.TimeTable;
import org.kaoriha.flowerflower.compile.document.Chronicle;
import org.kaoriha.flowerflower.compile.document.Depot;
import org.xml.sax.SAXException;

public class Compiler2 {
	private static final int NOW_TORELANCE_MIN = 2;
	private static final int MIN_PUBLICATION_INTERVAL_MIN = 60;
	private static final int QUICK_FIX_MIN = 10;
	private static final int QUICK_FIX_ABANDON_MIN = 15;

	/**
	 * args: source.xml (--init | #depot#) #timeTable#
	 * 
	 *  #depot#
	 * 		http://example.com/foobar/ # from remote
	 * 		foobar # from local
	 * 
	 * #timeTable#
	 * 		tt.json	# always from local
	 * 
	 * @param args
	 * @throws SAXException 
	 * @throws JAXBException 
	 * @throws ClassNotFoundException 
	 * @throws IOException 
	 */
	public static void main(String[] args) throws ClassNotFoundException, JAXBException, SAXException, IOException {
		DateTime now = DateTime.now().plusMinutes(NOW_TORELANCE_MIN);

		ArrayList<String> s = new ArrayList<String>(Arrays.asList(args));
		if (s.size() < 3) throw new IllegalArgumentException("Arguments: source.xml (--init | #depot#) timetable.json");

		String sourceFilename = s.get(0);
		String depotLocation = s.get(1);
		String timeTableFilename = s.get(2);

		// ソースからChronicleを構築
		SourceProcessor sp = new SourceProcessor("org.kaoriha.flowerflower._20111001");
		sp.parse(sourceFilename);
		Chronicle chronicle = sp.getDocumentHandler().getChronicle();

		// リモートからDepotを構築、publication idの履歴を得る
		Depot publishedDepot = new Depot();
		List<String> publishedIdList = new ArrayList<String>();
		String lastPublishedId = null;
		if (depotLocation.equals("--init")) {
			File ttf = new File(timeTableFilename);
			if (ttf.exists()) {
				if (!ttf.delete()) throw new IllegalArgumentException("cannot delete file:" + timeTableFilename);
			}
		} else {
			publishedIdList = publishedDepot.load(depotLocation);
			lastPublishedId = publishedIdList.get(publishedIdList.size() - 1);
		}

		// TimeTableをロード、発行済みのpublication idとソースにないidを消す
		TimeTable timeTable = new TimeTable(timeTableFilename);
		if (lastPublishedId != null) {
			for (String id : publishedIdList) {
				timeTable.remove(id);
			}
			Set<Map.Entry<DateTime, String>> toRemove = new HashSet<Map.Entry<DateTime,String>>();
			for (Map.Entry<DateTime, String> e : timeTable.getList()) {
				if (publishedIdList.contains(e.getValue())) {
					toRemove.add(e);
				} else if (!chronicle.getSeparationIdSet().contains(e.getValue())) {
					toRemove.add(e);
				}
			}
			for (Map.Entry<DateTime, String> e : toRemove) {
				timeTable.remove(e.getValue());
			}
		}

		// publication idの履歴のなかで最後にseparation idと重なるidを探す。重なったところをbase idとする
		String baseId = null;
		List<String> futurePublishIdList = new ArrayList<String>(sp.getDocumentHandler().getSeparationIdList());
		if (lastPublishedId != null) {
			for (String id : sp.getDocumentHandler().getSeparationIdList()) {
				if (publishedIdList.contains(id)) {
					baseId = id;
				}
			}
			if (baseId != null) {
				while (!futurePublishIdList.get(0).equals(baseId)) {
					futurePublishIdList.remove(0);
				}
				futurePublishIdList.remove(0);
			}
		}
		
		// ソースのbase id時点のDepotとリモートのDepotを比較し、異なればquick fix publication idを作る
		if (baseId != null && !chronicle.getDepot(baseId).equals(publishedDepot)) {
			DateTime abandonLimit = now.plusMinutes(QUICK_FIX_ABANDON_MIN);
			if (timeTable.getList().first().getKey().isAfter(abandonLimit)) {
				// do nothing
			} else {
				String quickFixId = UUID.randomUUID().toString();
				chronicle.snapshot(quickFixId, chronicle.getDepot(baseId));
				timeTable.add(now.plusMinutes(QUICK_FIX_MIN), quickFixId);
				futurePublishIdList.add(0, quickFixId);
			}
		}
		if (lastPublishedId != null) {
			chronicle.snapshot(lastPublishedId, publishedDepot);
		}

		// 未来のpublication idに発行時刻を振る。TimeTableにあって矛盾がなければ採用する。矛盾すればエラーを出して止まる。なければ作る
		Predictor p = new Predictor(Constant.RELEASE_CRON_PATTERN, now.toDate());
		long limit = now.getMillis();
		long interval = MIN_PUBLICATION_INTERVAL_MIN * 60 * 1000;
		for (String pid : futurePublishIdList) {
			DateTime dt = timeTable.getDateTime(pid);
			long next = p.nextMatchingTime();
			if (dt == null) {
				timeTable.add(new DateTime(next), pid);
				limit = next + interval;
			} else {
				long specified = dt.getMillis();
				if (specified < limit) throw new IllegalArgumentException("unexecutable time table. publication id:" + pid);
				timeTable.add(new DateTime(specified), pid);
				limit = specified + interval;
				p = new Predictor(Constant.RELEASE_CRON_PATTERN, limit);
			}
		}

		// genフォルダに配信ファイルを生成
		File d = new File("gen");
		if (d.exists()) {
			if (!d.isDirectory()) throw new IllegalArgumentException("gen should be a directory.");
		} else if (!d.mkdir()) {
			throw new IllegalArgumentException("cannot create gen directory.");
		}
		List<String> separationIdList = new ArrayList<String>(publishedIdList);
		for (Map.Entry<DateTime, String> e : timeTable.getList()) {
			separationIdList.add(e.getValue());
		}
		Builder b = new Builder(sp.getDocumentHandler(), timeTable, lastPublishedId, d, separationIdList);
		b.build();

		// TimeTableを保存
		timeTable.remove(lastPublishedId);
		timeTable.save();
	}

}
