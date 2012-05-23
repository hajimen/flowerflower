#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement

from xml.etree import ElementTree
from xml.dom import minidom
import codecs, sys

def prettify(elem):
	"""Return a pretty-printed XML string for the Element.
	"""
	rough_string = ElementTree.tostring(elem, 'utf-8')
	reparsed = minidom.parseString(rough_string)
	return reparsed.toprettyxml(indent="	")

if len(sys.argv) == 1:
	print 'Usage: # python %s filename' % sys.argv[0]
	quit()

def removeLastLineIfBlank(blockElementList):
	ce = blockElementList[-1]
	if len(ce) == 0:
		return
	te = list(ce)[-1]
	if te.text == None or len(te.text.strip()) == 0:
		ce.remove(te)

def processLine(line, nextLine, blockElementList):
	ce = blockElementList[-1]
	if line.strip() == u'＊':
		removeLastLineIfBlank(blockElementList)
		ElementTree.SubElement(ce, "section")
		if nextLine == None or len(nextLine.strip()) == 0:
			return 2
	if line[0] == '\t' and len(blockElementList) == 1:
		removeLastLineIfBlank(blockElementList)
		divElement = ElementTree.SubElement(ce, "div", {'class' : 'indent'})
		blockElementList.append(divElement)
		ce = divElement
	elif line[0] != '\t' and len(blockElementList) > 1:
		blockElementList.pop()
		if len(line.strip()) == 0:
			return 1
	content = line.strip('\t\r\n')
	pe = ElementTree.SubElement(ce, "p")
	pe.text = content
	return 1

ElementTree.register_namespace('', 'http://kaoriha.org/flowerflower/20111001/')
ElementTree.register_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
rootElement = ElementTree.fromstring('''<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root xmlns="http://kaoriha.org/flowerflower/20111001/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://kaoriha.org/flowerflower/20111001/ schema/flowerflower.xsd"></root>''')

blockElementList = [rootElement]

sys.stdout = codecs.getwriter('utf_8')(sys.stdout)

beforeLine = None
nextLine = None

with codecs.open(sys.argv[1], mode='r', encoding='utf-8-sig') as f:
	lastLine = None
	step = 1
	for line in f:
		step = step - 1
		if step == 0:
			if lastLine == None:
				step = 1
			else:
				step = processLine(lastLine, line, blockElementList)
		lastLine = line
	processLine(lastLine, None, blockElementList)

print prettify(rootElement)
