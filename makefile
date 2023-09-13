.PHONY: clean
.PHONY: build
.PHONY: run
.PHONY: copy

SDK = $(shell egrep '^\s*SDKRoot' ~/.Playdate/config | head -n 1 | cut -c9-)
SDKBIN=$(SDK)/bin
GAME=$(notdir $(CURDIR))
SIM=Playdate Simulator

build: clean compile run

run: open

clean:
	rm -rf '$(GAME).pdx'

compile: Source/main.lua
	"$(SDKBIN)/pdc" 'Source' 'build/$(GAME).pdx'
	
open:
	open -a '$(SDKBIN)/$(SIM).app/Contents/MacOS/$(SIM)' 'build/$(GAME).pdx'

pre-build:
	mkdir -p build
	@echo ===INCREMENT BUILD NUMBER
	scripts/buildnum.sh

.PHONY: build-production
build-production: clean pre-build compile-production

.PHONY: compile-production
compile-production:
	"$(SDKBIN)/pdc" '-s' 'Source' 'build/$(GAME).pdx'
	@echo ===ZIP BUILD
	cd build && zip -r --quiet '$(GAME).pdx.zip' '$(GAME).pdx'

	