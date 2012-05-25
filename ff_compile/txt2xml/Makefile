target.xml: transient.tmp transient2target.patch
	python diff-patch.py --make-target transient.tmp transient2target.patch target.xml

transient.tmp: draft.txt
	python draft2transient.py draft.txt |xmllint --format - > transient.tmp

transient2target.patch:
	touch -a transient2target.patch

target.xml.modified: transient.tmp
	python diff-patch.py --make-patch transient.tmp transient2target.patch target.xml

compile: target.xml
	java -jar ff_compile-0.1.jar target.xml chronicle.bin timetable.json
	xmllint --format target.xml > target.tmp
	rm target.xml
	mv target.tmp target.xml
	python diff-patch.py --make-patch transient.tmp transient2target.patch target.xml
