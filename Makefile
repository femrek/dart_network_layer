.PHONY: release publish

# Usage: make release v=1.0.0-dev11
release:
	@if [ -z "$(v)" ]; then \
		echo "Error: Version 'v' is required. Usage: make release v=1.0.0-dev11"; \
		exit 1; \
	fi
	@if [ "$$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then \
		echo "Error: You must be on the 'main' branch to release."; \
		exit 1; \
	fi
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Error: Working directory is not clean. Commit or stash changes first."; \
		exit 1; \
	fi
	@echo "Preparing release for version $(v)"
	./scripts/update_version.sh $(v)
	./scripts/update_changelog.sh $(v)
	git commit -am "chore: release $(v)"
	git tag -a v$(v) -m "Release v$(v)"
	@echo "Publishing packages..."
	dart pub publish -C dart_network_layer_core
	dart pub publish -C dart_network_layer_dio
	git push origin main
	git push origin tag v$(v)
	@echo "Version v$(v) has been updated, committed, and tagged!"

publish:
	@echo "Publishing packages..."
	dart pub publish -C dart_network_layer_core
	dart pub publish -C dart_network_layer_dio
