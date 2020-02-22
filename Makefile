CARGO_BIN ?= `which cargo`
LIB_PATH ?= "../mikack-ffi"
.PHONY: buildlib test
buildlib:
	@( cd $(LIB_PATH) && $(CARGO_BIN) build --release )
	@mkdir libraries -p
	@cp $(LIB_PATH)/target/release/libmikack_ffi.so libraries/

test:
	@pub run test test
