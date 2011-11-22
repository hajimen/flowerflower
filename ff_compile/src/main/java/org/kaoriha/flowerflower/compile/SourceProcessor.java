package org.kaoriha.flowerflower.compile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.kaoriha.flowerflower._20111001.Root;
import org.kaoriha.flowerflower.compile.document.DocumentHandler;
import org.kaoriha.flowerflower.compile.document.ElementHandler;
import org.xml.sax.SAXException;

@SuppressWarnings("rawtypes")
public class SourceProcessor {
	private JAXBContext context;
	private Unmarshaller unmarshaller;
	private Map<Class, ElementHandler> classMap = new HashMap<Class, ElementHandler>();
	private DocumentHandler docHandler;
	private Root root;

	public SourceProcessor(String contextPath) throws JAXBException,
			ClassNotFoundException, SAXException {
		context = JAXBContext.newInstance(contextPath);
		unmarshaller = context.createUnmarshaller();
		SchemaFactory schemaFactory = SchemaFactory
				.newInstance("http://www.w3.org/2001/XMLSchema");
		Schema schema = schemaFactory.newSchema(new File("schema/flowerflower.xsd"));
		unmarshaller.setSchema(schema);

		Throwable t = null;
		try {
			Class c = Class.forName(Constant.PROJECT_NAME + ".Document");
			docHandler = (DocumentHandler) c.newInstance();
			return;
		} catch (ClassNotFoundException e) {
			t = e;
		} catch (InstantiationException e) {
			t = e;
		} catch (IllegalAccessException e) {
			t = e;
		}
		throw new ClassNotFoundException(
				"DocumentHandler implementation not found.", t);

	}

	public void parse(String sourceFilename) throws JAXBException {
		root = (Root) unmarshaller.unmarshal(new File(sourceFilename));
		docHandler.start();
		getElementHandler(root).handle(this, null, root);
		docHandler.end();
	}


	public void process(List l, Object currentObject) {
		ElementHandler currentHandler = getElementHandler(currentObject);
		for (Object o : l) {
			if (o instanceof JAXBElement) {
				o = ((JAXBElement) o).getValue();
			}

			if (o instanceof String) {
				currentHandler.text((String) o);
				continue;
			}

			ElementHandler h = getElementHandler(o);
			if (h == null) {
				continue;
			}

			h.handle(this, currentObject, o);
		}
	}

	public void save(String sourceFilename) throws JAXBException, IOException {
		Marshaller m = context.createMarshaller();
		m.setProperty(Marshaller.JAXB_SCHEMA_LOCATION, "http://kaoriha.org/flowerflower/20111001/ schema/flowerflower.xsd");
		m.setProperty("jaxb.formatted.output", Boolean.TRUE);
		OutputStream os = new FileOutputStream(sourceFilename);
		m.marshal(root, os);
		os.close();
	}

	@SuppressWarnings("unchecked")
	private ElementHandler getElementHandler(Object o) {
		Class ec = o.getClass();
		if (classMap.containsKey(ec)) {
			return classMap.get(ec);
		}

		String cname = ec.getCanonicalName();
		String name = cname.substring(cname.lastIndexOf('.') + 1);
		try {
			Class c = Class.forName(Constant.PROJECT_NAME + "."
					+ name);
			ElementHandler h = (ElementHandler) c.newInstance();
			h.setDocumentHandler(docHandler);
			classMap.put(ec, h);
			return h;
		} catch (ClassNotFoundException e) {
			System.err
					.println("ElementHandler implementation not found. element name:"
							+ name);
		} catch (InstantiationException e) {
		} catch (IllegalAccessException e) {
		}

		classMap.put(ec, null);
		return null;
	}

	public DocumentHandler getDocumentHandler() {
		return docHandler;
	}
}
