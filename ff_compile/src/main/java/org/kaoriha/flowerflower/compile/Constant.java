package org.kaoriha.flowerflower.compile;

import java.util.ResourceBundle;

public class Constant {
	private static final ResourceBundle RESOURCE = ResourceBundle
			.getBundle("flowerflower");

	public static final String PROJECT_NAME = RESOURCE.getString("projectName");

	public static final String RELEASE_CRON_PATTERN = RESOURCE.getString("releaseCronPattern");

	public static final String DATE_DIR_NAME_FORMAT = "yyyyMMdd_HHmm";

	public static final String CATALOGUE_FILENAME = "catalogue.json";
	public static final String CATALOGUE_LOCAL_KEY = "local";
	public static final String CATALOGUE_EXPRESS_KEY = "express";
	public static final String CATALOGUE_NEXT_RELEASE_SCHEDULE_KEY = "next_release";
	public static final String CATALOGUE_PUSH_MESSAGE = "push_message";

	public static final String AUTH_DIR_NAME = "Auth";
	public static final String PUBLIC_DIR_NAME = "Public";
	public static final String TOTAL_DIR_NAME = "Total";
	public static final String LATEST_SEPARATION_HTML_FILENAME = "latest.html";

	private static final ResourceBundle PROJECT_RESOURCE = ResourceBundle
			.getBundle(RESOURCE.getString("projectProperties"));

	public static final String CHARACTER_NOTE_INITIAL_KEY = "character_note";
	public static final String CHARACTER_NOTE_NAME = PROJECT_RESOURCE.getString("character_note_name");

	public static final String ABOUT_THIS_APP_INITIAL_KEY = "about_this_app";
	public static final String ABOUT_THIS_APP = PROJECT_RESOURCE.getString("about_this_app");

	public static final String LATEST_SEPARATION_NAME = PROJECT_RESOURCE.getString("latest_separation_name");

	public static class Html {
		public static final String FORMAT = PROJECT_RESOURCE.getString("html");
		public static final String TITLE = "title";
		public static final String INDEX = "index";
		public static final String CONTENT = "content";
		public static final String START_SID = "startSid";
	}

	public static class LatestSeparationHtml {
		public static final String FORMAT = PROJECT_RESOURCE.getString("latest_separation_html");
		public static final String TITLE = "title";
		public static final String INDEX = "index";
		public static final String CONTENT = "content";
		public static final String yyyy = "yyyy";
		public static final String MM = "MM";
		public static final String dd = "dd";
		public static final String START_SID = "startSid";
	}

	public static final String INDEX_KEY = "INDEX_KEY";

	public static class RequestAuthCookie {
		public static final String AUTH_CODE_PARAM_NAME = "authCode";
		public static final String PATH = "Office/Author/RequestAuthCookie.ashx";
	}

	public static final String DEFAULT_COOKIE_FILENAME = "cookie.bin";
}
