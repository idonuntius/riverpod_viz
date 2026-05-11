.PHONY: pub-get analyze test test-coverage build-and-copy run-example clean

## Run flutter pub get on all packages
pub-get:
	cd . && flutter pub get
	cd devtools_extension && flutter pub get
	cd example && flutter pub get

## Run flutter analyze on all packages
analyze:
	flutter analyze

## Run tests on all packages
test:
	flutter test
	cd devtools_extension && flutter test

## Run tests with coverage
test-coverage:
	flutter test --coverage
	cd devtools_extension && flutter test --coverage
	@echo "Coverage reports generated:"
	@echo "  coverage/lcov.info"
	@echo "  devtools_extension/coverage/lcov.info"

## Build the devtools extension and copy the bundle into extension/devtools
## (uses the canonical `devtools_extensions build_and_copy` command)
build-and-copy:
	cd devtools_extension && dart run devtools_extensions build_and_copy \
		--source=. --dest=../extension/devtools

## Run example app
run-example:
	cd example && flutter run -d chrome

## Clean all build artifacts
clean:
	flutter clean
	cd devtools_extension && flutter clean
	cd example && flutter clean
	rm -rf extension/devtools/build
