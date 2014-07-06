
# Copyright (c) 2014 Calin Crisan
# This file is part of motionEye.
#
# motionEye is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 

import datetime
import json
import logging
import os.path
import shutil
import signal
import subprocess
import tempfile
import time
import urllib2

from tornado.ioloop import IOLoop

import settings


_DOWNLOAD_URL = '%(root)s/%(owner)s/%(repo)s/get/%(version)s.tar.gz'
_LIST_VERSIONS_URL = '%(root)s/api/1.0/repositories/%(owner)s/%(repo)s/tags'
_DOWNLOAD_DIR = '/data/.firmware_update'
_DOWNLOAD_FILE_NAME = os.path.join(_DOWNLOAD_DIR, 'firmware')


# versions

def get_version():
    import motioneye
    
    return motioneye.VERSION


def get_all_versions():
    url = _LIST_VERSIONS_URL
    url += '?_=' + str(int(time.time())) # prevents caching
    
    try:
        logging.debug('fetching %s...' % url)
        
        response = urllib2.urlopen(url, timeout=settings.REMOTE_REQUEST_TIMEOUT)
        response = json.load(response)
        versions = response.keys()
        
        logging.debug('available versions: %(versions)s' % {
                'versions': ', '.join(versions)})
        
        return sorted(versions)

    except Exception as e:
        logging.error('could not get versions: %s' % e, exc_info=True)

    return []


def compare_versions(version1, version2):
    version1 = [int(n) for n in version1.split('.')]
    version2 = [int(n) for n in version2.split('.')]
    
    len1 = len(version1)
    len2 = len(version2)
    length = min(len1, len2)
    for i in xrange(length):
        p1 = version1[i]
        p2 = version2[i]
        
        if p1 < p2:
            return -1
        
        elif p1 > p2:
            return 1
    
    if len1 < len2:
        return -1
    
    elif len1 > len2:
        return 1
    
    else:
        return 0


# updating

def download(version):
    url = _DOWNLOAD_URL % {'version': version}
    url += '?_=' + str(int(time.time())) # prevents caching

    try:
        logging.debug('downloading %s...' % url)

        shutil.rmtree(_DOWNLOAD_DIR, ignore_errors=True)
        os.makedirs(_DOWNLOAD_DIR)
        subprocess.check_call(['/usr/bin/wget', url, '-O', _DOWNLOAD_FILE_NAME])

    except Exception as e:
        logging.error('could not download update: %s' % e)

        raise

    try:
        logging.debug('extracting %s...' % _DOWNLOAD_FILE_NAME)

        subprocess.check_call(['/usr/bin/tar', 'zxf', _DOWNLOAD_FILE_NAME, '-C', _DOWNLOAD_DIR])

    except Exception as e:
        logging.error('could not extract archive: %s' % e)
        
        raise


def perform_update(version):
    logging.info('updating to version %(version)s...' % {'version': version})
    
    logging.debug('unmounting boot partition')
    if os.system('/bin/umount /boot'):
        logging.error('failed to unmount boot partition')

        raise Exception('failed to unmount boot partition')

    try:
        logging.info('installing boot image')
        boot_img = os.path.join(_DOWNLOAD_DIR, 'boot.img')
        
        subprocess.check_call(['/bin/dd', 'if=' + boot_img, 'of=/dev/mmcblk0p1', 'bs=1M'])

    except Exception as e:
        logging.error('could not install boot image: %s' % e)

        raise

    logging.debug('mounting boot partition read-write')
    if os.system('/bin/mount -o rw /dev/mmcblk0p1 /boot'):
        logging.error('failed to mount boot partition')
    
        raise Exception('failed to mount boot partition')

    try:
        config_lines = [c.strip() for c in open('/boot/config.txt', 'r').readlines() if c.strip()]
        
    except Exception as e:
        logging.error('failed to read /boot/config.txt: %s' % e, exc_info=True)
        
        raise

    config_lines.append('initramfs fwupdater.gz')

    try:
        with open('/boot/config.txt', 'w') as f:
            for line in config_lines:
                f.write(line + '\n')
        
    except Exception as e:
        logging.error('failed to write /boot/config.txt: %s' % e, exc_info=True)
        
        raise
        
    logging.info('rebooting')

    if os.system('/sbin/reboot'):
        logging.error('failed to reboot')
        logging.info('hard rebooting')
        open('/proc/sysrq-trigger', 'w').write('b') # reboot

