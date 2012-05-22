#!/usr/bin/env python

from __future__ import with_statement

from xml.etree import ElementTree
from xml.dom import minidom
import codecs, sys

def prettify(elem):
    """Return a pretty-printed XML string for the Element.
    """
    rough_string = ElementTree.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="    ")

if len(sys.argv) == 1:
	print 'Usage: # python %s filename' % sys.argv[0]
	quit()

ElementTree.register_namespace('', 'http://kaoriha.org/flowerflower/20111001/')
ElementTree.register_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
rootElement = ElementTree.fromstring('''<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root xmlns="http://kaoriha.org/flowerflower/20111001/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://kaoriha.org/flowerflower/20111001/ schema/flowerflower.xsd"></root>''')

blockElementList = [rootElement]

sys.stdout = codecs.getwriter('utf_8')(sys.stdout)

with codecs.open(sys.argv[1], mode='r', encoding='utf-8-sig') as f:
	for line in f:
		content = line
		ce = blockElementList[-1]
		if content[0] == '\t' and len(blockElementList) == 1:
			divElement = ElementTree.SubElement(ce, "div", {'class' : 'indent'})
			blockElementList.append(divElement)
			ce = divElement
		elif content[0] != 't' and len(blockElementList) > 1:
			blockElementList.pop()
		content = content.strip()
		pe = ElementTree.SubElement(ce, "p")
		pe.text = content

print prettify(rootElement)
