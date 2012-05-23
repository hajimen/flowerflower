target.xml: transient.tmp transient2target.patch
	patch transient.tmp < transient2target.patch -o target.xml

transient.tmp: genko.txt
	python genko2transient.py genko.txt |xmllint --format - > transient.tmp

transient2target.patch:
	touch -a transient2target.patch

.IGNORE: target.xml.modified
target.xml.modified: transient.tmp
	diff -c transient.tmp target.xml > transient2target.patch

compile: target.xml
	java -jar ../ff_compile-0.1.jar target.xml chronicle.bin timetable.json
	xmllint --format target.xml > target.tmp
	rm target.xml
	mv target.tmp target.xml
