target.xml: transient.xml transient2target.patch
	patch transient.xml < transient2target.patch -o target.xml

transient.xml: genko.txt
	python genko2transient.py genko.txt > transient.xml

.IGNORE: target.xml.modified
target.xml.modified:
	diff -c transient.xml target.xml > transient2target.patch
