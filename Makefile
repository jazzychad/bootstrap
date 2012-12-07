CHECK := \033[32m✔\033[39m

# If make is run like `make V=1', then commands starting with $(AT)
# will be echoed.
V := 0
AT_0 := @
AT_1 :=
AT := $(AT_$(V))

all: bootstrap
	@echo "Thanks for using Bootstrap,"
	@echo "<3 @mdo and @fat"
#
# BUILD DOCS
#

docs: .stamp-docs
.stamp-docs: .stamp-bootstrap
	$(AT)node docs/build
	$(AT)cp img/* docs/assets/img/
	$(AT)cp js/*.js docs/assets/js/
	$(AT)cp js/tests/vendor/jquery.js docs/assets/js/
	@echo "Compiling documentation...                  ${CHECK} Done"
	@touch $@

#
# RUN JSHINT & QUNIT TESTS IN PHANTOMJS
#

test:
	$(AT)jshint js/*.js --config js/.jshintrc
	$(AT)jshint js/tests/unit/*.js --config js/.jshintrc
	$(AT)node js/tests/server.js &
	$(AT)phantomjs js/tests/phantom.js "http://localhost:3000/js/tests"
	$(AT)kill -9 `cat js/tests/pid.txt`
	$(AT)rm js/tests/pid.txt
	@echo "Running JSHint on javascript...             $(CHECK) Done"

#
# CLEANS THE ROOT DIRECTORY OF PRIOR BUILDS
#

clean:
	rm -f .stamp-*
	rm -rf bootstrap

#
# JS
#

JS_DIR := bootstrap/js

# List of _GENERATED_ js files.
JS := $(JS_DIR)/bootstrap.js $(JS_DIR)/bootstrap.min.js

# List of .js files that go into bootstrap.js
JS_SRC := \
	js/bootstrap-transition.js \
	js/bootstrap-alert.js \
	js/bootstrap-button.js \
	js/bootstrap-carousel.js \
	js/bootstrap-collapse.js \
	js/bootstrap-dropdown.js \
	js/bootstrap-modal.js \
	js/bootstrap-tooltip.js \
	js/bootstrap-popover.js \
	js/bootstrap-scrollspy.js \
	js/bootstrap-tab.js \
	js/bootstrap-typeahead.js \
	js/bootstrap-affix.js

JS_COPYRIGHT := /*!\n\
 * Bootstrap.js by @fat & @mdo\n\
 * Copyright 2012 Twitter, Inc.\n\
 * http://www.apache.org/licenses/LICENSE-2.0.txt\n\
 */

js: .stamp-js
.stamp-js: $(JS)
	@echo "Compiling and minifying javascript...       ${CHECK} Done"
	@touch $@
$(JS_DIR)/bootstrap.js: .stamp-mkdir $(JS_SRC)
	$(AT)cat $(JS_SRC) > $@

$(JS_DIR)/bootstrap.min.js: $(JS_DIR)/bootstrap.js
	$(AT)echo '$(JS_COPYRIGHT)' > $@
	$(AT)uglifyjs -nc $< >> $@

#
# CSS
#

CSS_DIR := bootstrap/css
# List of _GENERATED_ CSS files.
CSS := \
	$(CSS_DIR)/bootstrap.css \
	$(CSS_DIR)/bootstrap.min.css \
	$(CSS_DIR)/bootstrap-responsive.css \
	$(CSS_DIR)/bootstrap-responsive.min.css
RECESS_COMPILE = $(AT)recess --compile $< > $@
RECESS_COMPRESS = $(AT)recess --compress $< > $@

BOOTSTRAP := ./docs/assets/css/bootstrap.css
BOOTSTRAP_RESPONSIVE := ./docs/assets/css/bootstrap-responsive.css
BOOTSTRAP_LESS := less/bootstrap.less
BOOTSTRAP_RESPONSIVE_LESS := less/responsive.less

css: .stamp-css
.stamp-css: $(CSS)
	@echo "Compiling LESS with Recess...               $(CHECK) Done"
$(CSS_DIR)/bootstrap.css: \
  $(BOOTSTRAP_LESS) .stamp-mkdir less/*.less; $(RECESS_COMPILE)
$(CSS_DIR)/bootstrap.min.css: \
  $(BOOTSTRAP_LESS) .stamp-mkdir less/*.less; $(RECESS_COMPRESS)
$(CSS_DIR)/bootstrap-responsive.css: \
  $(BOOTSTRAP_RESPONSIVE_LESS) .stamp-mkdir less/*.less; $(RECESS_COMPILE)
$(CSS_DIR)/bootstrap-responsive.min.css: \
  $(BOOTSTRAP_RESPONSIVE_LESS) .stamp-mkdir less/*.less; $(RECESS_COMPRESS)

#
# IMAGES
#

IMG_DIR := bootstrap/img

.stamp-img: .stamp-mkdir img/*
	$(AT)cp img/* $(IMG_DIR)
	@touch $@

img: .stamp-img

# Ensure necessary directories are created.
.stamp-mkdir:
	$(AT)mkdir -p $(CSS_DIR) $(IMG_DIR) $(JS_DIR)
	@touch $@

#
# BUILD SIMPLE BOOTSTRAP DIRECTORY
# recess & uglifyjs are required
#

bootstrap: .stamp-bootstrap
.stamp-bootstrap: .stamp-css .stamp-img .stamp-js
	@echo "Bootstrap successfully built at `date +%I:%M%p`."
	@touch $@

#
# MAKE FOR GH-PAGES 4 FAT & MDO ONLY (O_O  )
#

gh-pages: bootstrap docs
	rm -f docs/assets/bootstrap.zip
	zip -r docs/assets/bootstrap.zip bootstrap
	rm -r bootstrap
	rm -f ../bootstrap-gh-pages/assets/bootstrap.zip
	node docs/build production
	cp -r docs/* ../bootstrap-gh-pages

#
# WATCH LESS FILES
#

watch:
	echo "Watching less files..."; \
	watchr -e "watch('less/.*\.less') { system 'make' }"

.PHONY: all bootstrap clean css docs gh-pages img js test watch
