#-------------------------------------------------------------------------------
# Copyright (c) 2010 Patrick Mueller
# Licensed under the MIT license: 
# http://www.opensource.org/licenses/mit-license.php
#-------------------------------------------------------------------------------

.PHONY : all build deploy test clean watch help vendor

#-------------------------------------------------------------------------------
all: help

#-------------------------------------------------------------------------------
build: 
	@echo 
	@echo ===========================================================
	@echo building into ./deploy
	@echo ===========================================================
	
	-@chmod -R +w deploy
	@rm -rf deploy/*
	
	@mkdir -p deploy/css
	@mkdir -p deploy/data
	@mkdir -p deploy/vendor
	@mkdir -p deploy/images
	
	@echo 
	@echo ===========================================================
	@echo copying static files
	@echo ===========================================================
	cp index-nm.html          deploy
	cp css/*                  deploy/css
	cp data/*                 deploy/data
	cp images/*               deploy/images
	cp vendor/jquery/*.js     deploy/vendor
	cp vendor/modjewel/*.js   deploy/vendor
	cp vendor/json2/*.js      deploy/vendor
	
	@echo 
	@echo ===========================================================
	@echo compiling coffee files to JavaScript
	@echo ===========================================================
	@rm -rf tmp
	@mkdir tmp
	coffee --bare --output tmp/ --compile modules/
	python vendor/modjewel/module2amd.py --out deploy/modules tmp
	
	@echo 
	@echo ===========================================================
	@echo converting CommonJS modules to AMD format
	@echo ===========================================================
	python vendor/modjewel/module2amd.py --out deploy/modules      tmp
	python vendor/modjewel/module2amd.py --out deploy/vendor vendor/backbone
	python vendor/modjewel/module2amd.py --out deploy/vendor vendor/underscore
	python vendor/modjewel/module2amd.py --out deploy/vendor vendor/node-ical
	
	@echo 
	@echo ===========================================================
	@echo appcache-ing
	@echo ===========================================================
	sed "s/not-a-manifest/manifest/" \
	    < deploy/index-nm.html \
	    > deploy/index.html
	    
	cd deploy; \
	    find  . -type f -print | \
	    sed s/^\.\.// | \
        grep -v "\.htaccess" | \
	    grep -v "data/" | \
	    grep -v "index-nm.html" \
	    > ../tmp/index.manifest.files
	    
	echo "CACHE MANIFEST"         > deploy/index.manifest
	echo "# `date`"              >> deploy/index.manifest
	echo                         >> deploy/index.manifest
	cat tmp/index.manifest.files >> deploy/index.manifest
	echo                         >> deploy/index.manifest
	echo "NETWORK:"              >> deploy/index.manifest
	echo "http://oscon-2011.muellerware.org/data/oscon.ics" >> deploy/index.manifest
	echo "http://oscon-2011.muellerware.org/data/data.ics" >> deploy/index.manifest
	echo "http://oscon-2011.muellerware.org/data/java.ics" >> deploy/index.manifest

	@echo 
	@echo ===========================================================
	@echo building .htaccess files
	@echo ===========================================================
	echo "AddType text/cache-manifest .manifest"        > deploy/.htaccess
	echo "Header set Access-Control-Allow-Origin \"*\"" > deploy/data/.htaccess
	
	@chmod -R -w deploy/*
	
	@echo
	
	@growlnotify -m "oscon-2011 build finished" at `date +%H:%M:%S`

#-------------------------------------------------------------------------------
deploy:
	@chmod -R +w deploy
	rsync -av deploy/ muellerware.org:web/public/oscon-2011
	@chmod -R -w deploy

	#-------------------------------------------------------------------------------
deployGSA:
	@chmod -R +w deploy
	scp -r deploy/* pmuellr@rtpgsa.ibm.com:web/oscon-2011
	@chmod -R -w deploy

#-------------------------------------------------------------------------------
clean:
	@chmod -R +w deploy
	rm -rf tmp
	rm -rf deploy
	rm -rf vendor

#-------------------------------------------------------------------------------
watch: build
	@python vendor/run-when-changed/run-when-changed.py "make build" *

#-------------------------------------------------------------------------------
vendor: vendor-prep \
        vendor-modjewel \
        vendor-run-when-changed \
        vendor-node-ical \
        vendor-jquery \
        vendor-backbone \
        vendor-underscore \
        vendor-json2

#-------------------------------------------------------------------------------
vendor-prep:
	@echo 
	@echo ===========================================================
	@echo getting vendor files
	@echo ===========================================================
	@rm -rf vendor
	@mkdir vendor

#-------------------------------------------------------------------------------
vendor-node-ical:
	@echo 
	@echo ===========================================================
	@echo downloading node-ical
	@echo ===========================================================
	@mkdir  vendor/node-ical
	curl --silent --show-error --output vendor/node-ical/ical.js $(NODE_ICAL_URL)/$(NODE_ICAL_VERSION)/ical.js

#-------------------------------------------------------------------------------
vendor-underscore:
	@echo 
	@echo ===========================================================
	@echo downloading underscore
	@echo ===========================================================
	@mkdir  vendor/underscore
	curl --silent --show-error --output vendor/underscore/underscore.js $(UNDERSCORE_URL)/$(UNDERSCORE_VERSION)/underscore.js

#-------------------------------------------------------------------------------
vendor-backbone:
	@echo 
	@echo ===========================================================
	@echo downloading backbone
	@echo ===========================================================
	@mkdir  vendor/backbone
	curl --silent --show-error --output vendor/backbone/backbone.js $(BACKBONE_URL)/$(BACKBONE_VERSION)/backbone.js

#-------------------------------------------------------------------------------
vendor-jquery:
	@echo 
	@echo ===========================================================
	@echo downloading jquery
	@echo ===========================================================
	@mkdir  vendor/jquery
	curl --silent --show-error --output vendor/jquery/jquery-$(JQUERY_VERSION).min.js  $(JQUERY_URL)/jquery-$(JQUERY_VERSION).min.js

#-------------------------------------------------------------------------------
vendor-modjewel:
	@echo 
	@echo ===========================================================
	@echo downloading modjewel
	@echo ===========================================================
	@mkdir  vendor/modjewel
	curl --silent --show-error --output vendor/modjewel/modjewel-require.js  $(MODJEWEL_URL)/$(MODJEWEL_VERSION)/modjewel-require.js 
	curl --silent --show-error --output vendor/modjewel/module2amd.py $(MODJEWEL_URL)/$(MODJEWEL_VERSION)/module2amd.py

#-------------------------------------------------------------------------------
vendor-json2:
	@echo 
	@echo ===========================================================
	@echo downloading json2
	@echo ===========================================================
	@mkdir  vendor/json2
	curl --silent --show-error --output vendor/json2/json2.js $(JSON2_URL)/$(JSON2_VERSION)/json2.js

#-------------------------------------------------------------------------------
vendor-run-when-changed:
	@echo 
	@echo ===========================================================
	@echo downloading run-when-changed
	@echo ===========================================================
	mkdir   vendor/run-when-changed
	curl --silent --show-error --output vendor/run-when-changed/run-when-changed.py $(RUN_WHEN_CHANGED_URL)

#-------------------------------------------------------------------------------
help:
	@echo make targets available:
	@echo "  help     print this help"
	@echo "  build    build the junk"
	@echo "  deploy   copy to the server"
	@echo "  clean    clean up transient goop"
	@echo "  watch    run 'make build' when a file changes"
	@echo "  vendor   get the vendor files"
	@echo
	@echo You will need to run \'make vendor\' before doing a build.
	
#-------------------------------------------------------------------------------

LOCAL_DEPLOY           = ~/Sites/Public/mwa-fqf2011

MODJEWEL_URL           = https://raw.github.com/pmuellr/modjewel
MODJEWEL_VERSION       = 1.2.0

NODE_ICAL_URL          = https://raw.github.com/pmuellr/node-ical
NODE_ICAL_VERSION      = patch-1

UNDERSCORE_URL         = https://raw.github.com/documentcloud/underscore
UNDERSCORE_VERSION     = 1.1.6

BACKBONE_URL           = https://raw.github.com/documentcloud/backbone
BACKBONE_VERSION       = 0.5.1

QUNIT_URL              = https://raw.github.com/jquery/qunit
QUNIT_VERSION          = master

JSON2_URL              = https://raw.github.com/douglascrockford/JSON-js
JSON2_VERSION          = master

JQUERY_URL             = http://code.jquery.com
JQUERY_VERSION         = 1.6

RUN_WHEN_CHANGED_URL   = https://raw.github.com/gist/240922/0f5bedfc42b3422d0dee81fb794afde9f58ed1a6/run-when-changed.py

