CARGO_BIN ?= `which cargo`
LIB_PATH ?= "../mikack-ffi"
.PHONY: buildlib test ntest fmt
buildlib:
	@( cd $(LIB_PATH) && $(CARGO_BIN) build --release )
	@mkdir libraries -p
	@cp $(LIB_PATH)/target/release/libmikack_ffi.so libraries/

test:
	@pub run test test

ntest:
	@dart2native test/api_test.dart -o api_test.native
	@./api_test.native
	@rm ./api_test.native
fmt:
	@dartfmt -w `pwd`