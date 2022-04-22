.PHONY: install
install:
	bundle install --path vendor/bundle

.PHONY: init
init:
	cp settings.yml .settings.yml
