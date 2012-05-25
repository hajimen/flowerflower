#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement

"""diff-patch.py

微妙に書式のあるテキストファイル（draft.txt）とパッチファイル（transient2target.patch）と
コンパイラのソース（target.xml）のあいだの関係を保つ。

引数:
	diff-patch.py [option] transient.tmp transient2target.patch target.xml

オプション:
--make-target
	transient.tmpとtransient2target.patchからtarget.xmlを生成する

--make-patch
	transient.tmpとtarget.xmlからtransient2target.patchを生成する
"""


import codecs, sys
from diff_match_patch import diff_match_patch
dmp = diff_match_patch()

sys.stdout = codecs.getwriter('utf_8')(sys.stdout)

def read_content(filename):
	f = codecs.open(filename, mode='r', encoding='utf-8-sig')
	content = f.read()
	f.close()
	return content

def make_target(fn_transient, fn_patch, fn_target):
	transient = read_content(fn_transient)
	patch_text = read_content(fn_patch)
	patches = dmp.patch_fromText(patch_text)
	target = dmp.patch_apply(patches, transient)[0]
	f = codecs.open(fn_target, mode='w', encoding='utf-8')
	f.write(target)
	f.close()

def make_patch(fn_transient, fn_patch, fn_target):
	transient = read_content(fn_transient)
	target = read_content(fn_target)
	diffs = dmp.diff_main(transient, target)
	dmp.diff_cleanupSemantic(diffs)
	patches = dmp.patch_make(transient, diffs)
	patch_text = dmp.patch_toText(patches)
	f = codecs.open(fn_patch, mode='w', encoding='utf-8-sig')
	f.write(patch_text)
	f.close()

def usage():
	print """Arguments: [option] transient.tmp transient2target.patch target.xml
Options:
--make-target
--make-patch"""

if len(sys.argv) < 5:
	usage()
elif sys.argv[1] == '--make-target':
	make_target(sys.argv[2], sys.argv[3], sys.argv[4])
elif sys.argv[1] == '--make-patch':
	make_patch(sys.argv[2], sys.argv[3], sys.argv[4])
else:
	usage()


