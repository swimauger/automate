build:
	@mkdir -p lib
	swiftc -emit-library src/swift/peripherals.swift -o lib/libperipherals.dylib

run:
	python3 src/python/main.py
