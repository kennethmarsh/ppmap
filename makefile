# Start of Makefile
# Set shell
SHELL:=/bin/bash

# Define user config file
USRNAME = c.c1234567

# Define directories
# Source directory
SRCDIR = src
# Install directory
BINDIR = bin

# Define compiler load commands
PURGE = module purge
COMPILER = $(shell sed -n -e "s+COMPILER=++p" ./config.cfg)
LOAD  = module load $(COMPILER)

# Define compiler
F90COMP = ifort -O3 -o

# Define source files
# PreMAP source files
SRCPRFLS = premap.f90 getnoise.f90 convol.f90 resample.f90 regrid.f90 intrp2.f divider.f90 radec2pix.f90 pixcrot.f90 removeblanks.f90 readheader.f readimage_wcs.f writeimage_wcs.f writeimage3d.f
# PPMAP  source files
SRCPPFLS = matmul_omp.f90 ppmap.f90 hpcorr.f90 rchisqindcalc.f90 ppmosaic.f90 pperr.f90 convol.f90 inversep.f90 nmedian.f90 trimavg.f90 refmodelcalc.f90 planckfn.f90 tau2mass.f90 intrp2.f radec2pix.f90 pixcrot.f90 removeblanks.f90 readheader.f readheader3d.f readheader4d.f readimage_basic.f readimage_wcs.f readimage3d.f readrho.f writerho.f writeimage2d.f

# Define full source paths
SRCPR = $(addprefix $(SRCDIR)/,$(SRCPRFLS))
SRCPP = $(addprefix $(SRCDIR)/,$(SRCPPFLS))

#$(info PRsrc: $(SRCPR))
#$(info PPsrc: $(SRCPP))

# Makefile
# Build PreMAP and PPMAP
build: $(BINDIR) userEdit $(BINDIR)/premap $(BINDIR)/ppmap

# Create bin directory
$(BINDIR): 
	@mkdir $@
	echo "Making the bin directory: $(BINDIR)"

# Compile PreMAP
$(BINDIR)/premap: $(SRCPR) $(SRCDIR)/libcfitsio.a
	@. /usr/share/Modules/init/bash; \
	echo "Compiling Premap in $(BINDIR)"
	$(PURGE); \
	$(LOAD); \
	$(F90COMP) $(BINDIR)/premap $(SRCPR) -fopenmp -L$(SRCDIR) -lcfitsio

# Compile PPMAP
$(BINDIR)/ppmap: $(SRCPP) $(SRCDIR)/libcfitsio.a
	@. /usr/share/Modules/init/bash; \
	echo "Compiling PPMAP in $(BINDIR)"
	$(PURGE); \
	$(LOAD); \
	$(F90COMP) $(BINDIR)/ppmap $(SRCPP) -fopenmp -L$(SRCDIR) -lcfitsio

# Edit Username in Shell Scripts
userEdit:
	@. /usr/share/Modules/init/bash; \
	echo "Editing the template files with config options"
	chmod -x ./etc/editTemplates;\
	sh ./etc/editTemplates

# Remove PPMAP and PreMAP
remove: $(BINDIR)/ppmap $(BINDIR)/premap
	rm $(BINDIR)/ppmap
	rm $(BINDIR)/premap
