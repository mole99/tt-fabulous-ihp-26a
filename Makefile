PDK ?= ihp-sg13g2

# Get the fabric names
FABRICS :=  $(patsubst fabrics/%,%,$(wildcard fabrics/*)) 

FABRICS_OPENROAD := $(addsuffix -openroad,$(FABRICS))
FABRICS_KLAYOUT := $(addsuffix -klayout,$(FABRICS))

all: $(FABRICS)
.PHONY: all

$(FABRICS):
	librelane --pdk ${PDK} fabrics/$@/config.yaml --save-views-to fabrics/$@/macro/${PDK}/
.PHONY: $(FABRICS)

$(FABRICS_OPENROAD):
	librelane --pdk ${PDK} fabrics/$(subst -openroad,,$@)/config.yaml --last-run --flow OpenInOpenROAD
.PHONY: $(FABRICS_OPENROAD)

$(FABRICS_KLAYOUT):
	librelane --pdk ${PDK} fabrics/$(subst -klayout,,$@)/config.yaml --last-run --flow OpenInKLayout
.PHONY: $(FABRICS_KLAYOUT)

copy-fabric:
	# Copy fabric database
	mkdir -p user_designs/fabrics/tiny_fabric_5x5/macro/ihp-sg13g2/
	cp -R fabrics/tiny_fabric_5x5/macro/ihp-sg13g2/fabulous/ user_designs/fabrics/tiny_fabric_5x5/macro/ihp-sg13g2/
	cp fabrics/tiny_fabric_5x5/constraints.pcf user_designs/fabrics/tiny_fabric_5x5/constraints.pcf
.PHONY: copy-fabric

tt-fabulous:
	librelane config.yaml --pdk ${PDK} --save-views-to macro/
.PHONY: tt-fabulous

tt-fabulous-openroad:
	librelane config.yaml --pdk ${PDK} --last-run --flow OpenInOpenROAD
.PHONY: tt-fabulous

tt-fabulous-klayout:
	librelane config.yaml --pdk ${PDK} --last-run --flow OpenInKLayout
.PHONY: tt-fabulous

# Copy the files for Tiny Tapeout
copy-tt:
	# Copy GDS and LEF
	cp macro/gds/tt_um_fabulous_ihp_26a.gds gds/tt_um_fabulous_ihp_26a.gds
	cp macro/lef/tt_um_fabulous_ihp_26a.lef lef/tt_um_fabulous_ihp_26a.lef
.PHONY: copy-tt
