target.xml: transient.tmp transient2target.patch
	patch transient.tmp < transient2target.patch -o target.xml

transient.tmp: draft.txt
	python draft2transient.py draft.txt |xmllint --format - > transient.tmp

transient2target.patch:
	touch -a transient2target.patch

target.xml.modified: transient.tmp
	diff -c transient.tmp target.xml > transient2target.patch || echo ""

compile: target.xml
	java -jar ff_compile-0.1.jar target.xml chronicle.bin timetable.json
	xmllint --format target.xml > target.tmp
	rm target.xml
	mv target.tmp target.xml
	diff -c transient.tmp target.xml > transient2target.patch || echo ""

