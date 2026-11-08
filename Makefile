GHDL      ?= ghdl
GHDLFLAGS := --std=08
BUILD     := build

SRC := src/seven_segment_decoder.vhd src/debounce.vhd src/stopwatch.vhd
TB  := sim/tb_seven_segment_decoder.vhd sim/tb_debounce.vhd sim/tb_stopwatch.vhd
LIB := $(BUILD)/work-obj08.cf

.PHONY: test decoder debounce stopwatch clean

test: decoder debounce stopwatch
	@echo "All testbenches passed."

$(LIB): $(SRC) $(TB)
	@mkdir -p $(BUILD)
	cd $(BUILD) && $(GHDL) -a $(GHDLFLAGS) $(addprefix ../,$(SRC) $(TB))

decoder: $(LIB)
	cd $(BUILD) && $(GHDL) --elab-run $(GHDLFLAGS) tb_seven_segment_decoder

debounce: $(LIB)
	cd $(BUILD) && $(GHDL) --elab-run $(GHDLFLAGS) tb_debounce

stopwatch: $(LIB)
	cd $(BUILD) && $(GHDL) --elab-run $(GHDLFLAGS) tb_stopwatch

clean:
	rm -rf $(BUILD)
