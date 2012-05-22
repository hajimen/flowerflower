#!/usr/bin/env python

from __future__ import with_statement

from errno import EACCES
from os.path import realpath
from sys import argv, exit
from threading import Lock
import subprocess

import os

from fuse import FUSE, FuseOSError, Operations, LoggingMixIn


class MakeCaller:
    def _hasMakefile(self, path):
        return os.path.exists(os.path.dirname(path) + "/Makefile")

    def afterModify(self, path):
        if os.path.isdir(path):
            return
        if not self._hasMakefile(path):
            return
        subprocess.call(["make", os.path.basename(path) + ".modified"], cwd=os.path.dirname(path))
        print "afterModify called"

    def beforeRead(self, path):
        if not self._hasMakefile(path):
            return
        if os.path.isdir(path):
            subprocess.call(["make"], cwd=path)
        else:
            subprocess.call(["make", os.path.basename(path)], cwd=os.path.dirname(path))
        print "beforeRead called"


class AutoMatker(LoggingMixIn, Operations):    
    def __init__(self, root):
        self.root = realpath(root)
        self.makeCaller = MakeCaller()
        self.rwlock = Lock()
    
    def __call__(self, op, path, *args):
        return super(AutoMatker, self).__call__(op, self.root + path, *args)
    
    def access(self, path, mode):
        if not os.access(path, mode):
            raise FuseOSError(EACCES)
    
    chmod = os.chmod
    chown = os.chown
    
    def create(self, path, mode):
        return os.open(path, os.O_WRONLY | os.O_CREAT, mode)
    
    def flush(self, path, fh):
        ret = os.fsync(fh)
        # self.makeCaller.afterModify(path)
        return ret

    def fsync(self, path, datasync, fh):
        ret = os.fsync(fh)
        # self.makeCaller.afterModify(path)
        return ret
                
    def getattr(self, path, fh=None):
        self.makeCaller.beforeRead(path)
        st = os.lstat(path)
        return dict((key, getattr(st, key)) for key in ('st_atime', 'st_ctime',
            'st_gid', 'st_mode', 'st_mtime', 'st_nlink', 'st_size', 'st_uid'))
    
    getxattr = None
    
    def link(self, target, source):
        ret = os.link(source, target)
        self.makeCaller.afterModify(target)
        return ret
    
    listxattr = None
    mkdir = os.mkdir
    mknod = os.mknod

    def open(self, path, flags):
        self.makeCaller.beforeRead(path)
        return os.open(path, flags)
        
    def read(self, path, size, offset, fh):
        with self.rwlock:
            os.lseek(fh, offset, 0)
            return os.read(fh, size)
    
    def readdir(self, path, fh):
        return ['.', '..'] + os.listdir(path)

    readlink = os.readlink
    
    def release(self, path, fh):
        ret = os.close(fh)
        self.makeCaller.afterModify(path)
        return ret
        
    def rename(self, old, new):
        ret = os.rename(old, self.root + new)
        self.makeCaller.afterModify(new)
        return ret
    
    rmdir = os.rmdir
    
    def statfs(self, path):
        self.makeCaller.beforeRead(path)
        stv = os.statvfs(path)
        return dict((key, getattr(stv, key)) for key in ('f_bavail', 'f_bfree',
            'f_blocks', 'f_bsize', 'f_favail', 'f_ffree', 'f_files', 'f_flag',
            'f_frsize', 'f_namemax'))
    
    def symlink(self, target, source):
        ret = os.symlink(source, target)
        self.makeCaller.afterModify(target)
        return ret
    
    def truncate(self, path, length, fh=None):
        with open(path, 'r+') as f:
            f.truncate(length)
        self.makeCaller.afterModify(path)
    
    unlink = os.unlink
    utimens = os.utime
    
    def write(self, path, data, offset, fh):
        with self.rwlock:
            os.lseek(fh, offset, 0)
            return os.write(fh, data)
    

if __name__ == "__main__":
    if len(argv) != 3:
        print 'usage: %s <root> <mountpoint>' % argv[0]
        exit(1)
    fuse = FUSE(AutoMatker(argv[1]), argv[2], foreground=True)
