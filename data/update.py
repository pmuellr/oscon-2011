#!/usr/bin/env python

import urllib

urls = {
    "oscon.ics": "http://www.oscon.com/oscon2011/public/schedule/ical/oscon",
    "data.ics":  "http://www.oscon.com/oscon2011/public/schedule/ical/data",
    "java.ics":  "http://www.oscon.com/oscon2011/public/schedule/ical/java"
}

for (name, url) in urls.iteritems():
    print "downloading %s" % url
    urllib.urlretrieve(url, name)