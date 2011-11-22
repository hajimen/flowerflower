package org.kaoriha.flowerflower.compile;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.joda.time.DateTime;
import org.kaoriha.flowerflower.compile.document.Chronicle;

public class Merger {
	public static void prepareNewTimeTable(Chronicle chronicle, TimeTable timeTable) {
		DateTime dt = DateTime.now().toLocalDate().toDateTime(Constant.RELEASE_TIME);
		if (dt.isBefore(DateTime.now().plusHours(1))) {
			dt = dt.plusDays(1);
		}
		timeTable.getMap().clear();
		for (Chronicle.Entry e : chronicle.getEntryList()) {
			timeTable.getMap().put(dt, e.getSeparationId());
			dt = dt.plusDays(1);
		}
	}

	public static void prepareNewTestTimeTable(Chronicle chronicle, TimeTable timeTable, DateTime startTime) {
		DateTime dt = startTime.plusMinutes(0);
		for (Chronicle.Entry e : chronicle.getEntryList()) {
			timeTable.getMap().put(dt, e.getSeparationId());
			dt = dt.plus(Constant.TEST_RELEASE_PERIOD);
		}
	}

	public static Chronicle run(Chronicle newChronicle, Chronicle oldChronicle, TimeTable timeTable, String lastReleasedSeparationId) {
		DateTime lastReleasedDT = null;
		TreeMap<DateTime, String> ttm = timeTable.getMap();
		Set<String> releasedSeparationIdSet = new HashSet<String>();
		for (Map.Entry<DateTime, String> e : ttm.entrySet()) {
			releasedSeparationIdSet.add(e.getValue());
			if (e.getValue().equals(lastReleasedSeparationId)) {
				lastReleasedDT = e.getKey();
				break;
			}
		}
		if (lastReleasedDT == null) {
			throw new IllegalArgumentException("lastReleasedSeparationId " + lastReleasedSeparationId + " is out of timeTable.");
		}

		Chronicle ret = new Chronicle();
		for (Chronicle.Entry e : oldChronicle.getEntryList()) {
			if (releasedSeparationIdSet.contains(e.getSeparationId())) {
				ret.snapshot(e.getSeparationId(), e.getDepot());
			}
		}
		List<String> futureSeparationIdList = new ArrayList<String>();
		for (Chronicle.Entry e : newChronicle.getEntryList()) {
			if (!releasedSeparationIdSet.contains(e.getSeparationId())) {
				futureSeparationIdList.add(e.getSeparationId());
				ret.snapshot(e.getSeparationId(), e.getDepot());
			}
		}
		
		for (Iterator<Map.Entry<DateTime, String>> i = ttm.entrySet().iterator(); i.hasNext(); ) {
			Map.Entry<DateTime, String> e = i.next();
			if (e.getKey().isAfter(lastReleasedDT)) {
				i.remove();
			}
		}
		
		if (Constant.TEST_RELEASE_PERIOD == null) {
			DateTime nextDay = new DateTime(lastReleasedDT);
			for (String sid : futureSeparationIdList) {
				nextDay = nextDay.plusDays(1);
				DateTime dt = nextDay.toLocalDate().toDateTime(Constant.RELEASE_TIME);
				ttm.put(dt, sid);
			}
		} else {
			DateTime ndt = new DateTime(lastReleasedDT);
			for (String sid : futureSeparationIdList) {
				ndt = ndt.plus(Constant.TEST_RELEASE_PERIOD);
				ttm.put(ndt, sid);
			}
		}

		return ret;
	}
}
