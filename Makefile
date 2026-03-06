VERSION_PURE := $(shell grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}')
VERSION := v$(VERSION_PURE)
PACKAGES := dart_network_layer_core dart_network_layer_dio

generate_changelogs:
	git cliff -o CHANGELOG.md
	python3 ./scripts/change_log_reader.py ./CHANGELOG.md $(VERSION) >> temp_change_log
	cat temp_change_log
	python3 ./scripts/change_log_inserter.py temp_change_log $(VERSION) dart_network_layer_core/CHANGELOG.md
	python3 ./scripts/change_log_inserter.py temp_change_log $(VERSION) dart_network_layer_dio/CHANGELOG.md
	rm temp_change_log

publish:
	@for package in $(PACKAGES); do \
		echo "Publishing $$package..."; \
		cd $$package; \
		dart pub publish --force; \
		cd -; \
	done

