target.xml: transient.tmp transient2target.patch
	patch transient.tmp < transient2target.patch -o target.xml

transient.tmp: genko.txt
	python genko2transient.py genko.txt > transient.tmp

.IGNORE: target.xml.modified
target.xml.modified: transient.tmp
	diff -c transient.tmp target.xml > transient2target.patch
