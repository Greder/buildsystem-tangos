#
# set up build environment for other makefiles
#
# -----------------------------------------------------------------------------

#SHELL := $(SHELL) -x

CONFIG_SITE =
export CONFIG_SITE

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

# -----------------------------------------------------------------------------

# set up default parallelism
PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS)) $(SILENT_OPT)

MAKEFLAGS             += --no-print-directory

# -----------------------------------------------------------------------------

# default platform...
BASE_DIR             := $(shell pwd)
ARCHIVE              ?= $(HOME)/Archive
TOOLS_DIR             = $(BASE_DIR)/tools
BUILD_TMP             = $(BASE_DIR)/build_tmp
SOURCE_DIR            = $(BASE_DIR)/build_source
DRIVER_DIR            = $(BASE_DIR)/driver
FLASH_DIR             = $(BASE_DIR)/flash
RELEASE_IMAGE_DIR     = $(BASE_DIR)/release_image

-include $(BASE_DIR)/config

# for local extensions
-include $(BASE_DIR)/config.local


GIT_PROTOCOL         ?= http
ifneq ($(GIT_PROTOCOL), http)
GITHUB               ?= git://github.com
else
GITHUB               ?= https://github.com
endif
GIT_NAME             ?= TangoCash
GIT_NAME_DRIVER      ?= Duckbox-Developers
GIT_NAME_TOOLS       ?= Duckbox-Developers
GIT_NAME_FLASH       ?= Duckbox-Developers

# default config...
BOXARCH              ?= arm
BOXTYPE              ?= hd51
FFMPEG_EXPERIMENTAL  ?= 1
OPTIMIZATIONS        ?= size
MEDIAFW              ?= buildinplayer
IMAGE                ?= neutrino
FLAVOUR              ?= neutrino-tangos
EXTERNAL_LCD         ?= both
NEWLAYOUT            ?= 0
#
ITYPE                ?= usb

TUFSBOX_DIR           = $(BASE_DIR)/tufsbox
CROSS_BASE            = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXTYPE)
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k))
BOXCPU                = bcm7376
CROSS_BASE            = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXCPU)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
BOXCPU                = bcm7278
CROSS_BASE            = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXCPU)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60 hd61))
BOXCPU                = Hi3798Mv200
CROSS_BASE            = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXCPU)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 bre2ze4k h7))
BOXCPU                = bcm7251s
CROSS_BASE            = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXCPU)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo))
BOXCPU                = bcm7335
CROSS_BASE            = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXCPU)
endif

TARGET_DIR            = $(TUFSBOX_DIR)/cdkroot
CROSS_DIR             = $(TUFSBOX_DIR)/cross
HOST_DIR              = $(TUFSBOX_DIR)/host
RELEASE_DIR_CLEANUP   = $(TUFSBOX_DIR)/release
ifeq ($(NEWLAYOUT), $(filter $(NEWLAYOUT), 1))
RELEASE_DIR           = $(TUFSBOX_DIR)/release/linuxrootfs1
else
RELEASE_DIR           = $(TUFSBOX_DIR)/release
endif

CUSTOM_DIR            = $(BASE_DIR)/custom
OWN_BUILD             = $(BASE_DIR)/own_build
PATCHES               = $(BASE_DIR)/patches
HELPERS_DIR           = $(BASE_DIR)/helpers
SKEL_ROOT             = $(BASE_DIR)/root
D                     = $(BASE_DIR)/.deps

ifneq ($(SUDOPASSWD),)
SUDOCMD               = fakeroot
else
SUDOCMD               = echo $(SUDOPASSWD) | sudo -S
endif


MAINTAINER           ?= $(shell whoami)
MAIN_ID               = $(shell echo -en "\x74\x68\x6f\x6d\x61\x73")
CCACHE                = /usr/bin/ccache

BUILD                ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess 2>/dev/null || /usr/share/misc/config.guess 2>/dev/null)

ifeq ($(BOXARCH), sh4)
CCACHE_DIR            = $(HOME)/.ccache-bs-sh4
export CCACHE_DIR
TARGET               ?= sh4-linux
KERNELNAME            = uImage
TARGET_MARCH_CFLAGS   =
CORTEX_STRINGS        =
endif

ifeq ($(BOXARCH), arm)
CCACHE_DIR            = $(HOME)/.ccache-bs-arm
export CCACHE_DIR
TARGET               ?= arm-cortex-linux-gnueabihf
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd60 hd61))
KERNELNAME            = uImage
else
KERNELNAME            = zImage
endif
TARGET_MARCH_CFLAGS   = -march=armv7ve -mtune=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=hard
CORTEX_STRINGS        = -lcortex-strings
endif

ifeq ($(BOXARCH), mips)
CCACHE_DIR            = $(HOME)/.ccache-bs-mips
export CCACHE_DIR
TARGET               ?= mipsel-unknown-linux-gnu
KERNELNAME            = vmlinux
TARGET_MARCH_CFLAGS   = -march=mips32 -mtune=mips32
CORTEX_STRINGS        =
endif

ifeq ($(OPTIMIZATIONS), size)
TARGET_O_CFLAGS       = -Os
TARGET_EXTRA_CFLAGS   = -ffunction-sections -fdata-sections
TARGET_EXTRA_LDFLAGS  = -Wl,--gc-sections
endif
ifeq ($(OPTIMIZATIONS), normal)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif
ifeq ($(OPTIMIZATIONS), kerneldebug)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif
ifeq ($(OPTIMIZATIONS), debug)
TARGET_O_CFLAGS       = -O0 -g -ggdb
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif

# -----------------------------------------------------------------------------

TARGET_LIB_DIR        = $(TARGET_DIR)/usr/lib
TARGET_INCLUDE_DIR    = $(TARGET_DIR)/usr/include
TARGET_SHARE_DIR      = $(TARGET_DIR)/usr/share

TARGET_CFLAGS         = -pipe $(TARGET_O_CFLAGS) $(TARGET_MARCH_CFLAGS) $(TARGET_EXTRA_CFLAGS) -I$(TARGET_INCLUDE_DIR)
TARGET_CPPFLAGS       = $(TARGET_CFLAGS)
TARGET_CXXFLAGS       = $(TARGET_CFLAGS)
TARGET_LDFLAGS        = $(CORTEX_STRINGS) -Wl,-rpath -Wl,/usr/lib -Wl,-rpath-link -Wl,$(TARGET_LIB_DIR) -L$(TARGET_LIB_DIR) -L$(TARGET_DIR)/lib $(TARGET_EXTRA_LDFLAGS)
LD_FLAGS              = $(TARGET_LDFLAGS)
PKG_CONFIG            = $(HOST_DIR)/bin/$(TARGET)-pkg-config
PKG_CONFIG_PATH       = $(TARGET_LIB_DIR)/pkgconfig

VPATH                 = $(D)

PATH                 := $(HOST_DIR)/bin:$(CROSS_DIR)/bin:$(CROSS_BASE)/bin:$(PATH):/sbin:/usr/sbin:/usr/local/sbin

TERM_RED             := \033[00;31m
TERM_RED_BOLD        := \033[01;31m
TERM_GREEN           := \033[00;32m
TERM_GREEN_BOLD      := \033[01;32m
TERM_YELLOW          := \033[00;33m
TERM_YELLOW_BOLD     := \033[01;33m
TERM_NORMAL          := \033[0m

# -----------------------------------------------------------------------------

# To put more focus on warnings, be less verbose as default
# Use 'make V=1' to see the full commands
ifeq ("$(origin V)", "command line")
VERBOSE               = $(V)
endif

# If VERBOSE equals 0 then the above command will be hidden.
# If VERBOSE equals 1 then the above command is displayed.
ifeq ($(VERBOSE),1)
SILENT_PATCH          =
SILENT_OPT            =
SILENT                =
DOWNLOAD_SILENT_OPT   =
else
SILENT_PATCH          = -s
SILENT_OPT           := >/dev/null 2>&1
SILENT                = @
DOWNLOAD_SILENT_OPT   = -o /dev/null
MAKEFLAGS            += --silent
endif

# -----------------------------------------------------------------------------

# certificates
CA_BUNDLE             = ca-certificates.crt
CA_BUNDLE_DIR         = /etc/ssl/certs

# -----------------------------------------------------------------------------

# helper-"functions"
REWRITE_LIBTOOL       = sed -i "s,^libdir=.*,libdir='$(TARGET_DIR)/usr/lib'," $(TARGET_DIR)/usr/lib
REWRITE_LIBTOOLDEP    = sed -i -e "s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/usr/lib,\ $(TARGET_DIR)/usr/lib,g" $(TARGET_DIR)/usr/lib
REWRITE_PKGCONF       = sed -i "s,^prefix=.*,prefix='$(TARGET_DIR)/usr',"

# unpack tarballs, clean up
UNTAR                 = $(SILENT)tar -C $(BUILD_TMP) -xf $(ARCHIVE)
REMOVE                = $(SILENT)rm -rf $(BUILD_TMP)

# download tarballs into archive directory
DOWNLOAD = wget --progress=bar:force --no-check-certificate $(DOWNLOAD_SILENT_OPT) -t6 -T20 -c -P $(ARCHIVE)

CD                    = set -e; cd
CHDIR                 = $(CD) $(BUILD_TMP)
MKDIR                 = mkdir -p $(BUILD_TMP)
STRIP                 = $(TARGET)-strip

# -----------------------------------------------------------------------------

split_deps_dir=$(subst ., ,$(1))
DEPS_DIR              = $(subst $(D)/,,$@)
PKG_NAME              = $(word 1,$(call split_deps_dir,$(DEPS_DIR)))
PKG_NAME_HELPER       = $(shell echo $(PKG_NAME) | sed 's/.*/\U&/')
PKG_VER_HELPER        = A$($(PKG_NAME_HELPER)_VER)A
PKG_VER               = $($(PKG_NAME_HELPER)_VER)

START_BUILD           = $(call draw_line,$(PKG_NAME),6); \
                        echo; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL)"; \
                        else \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL)"; \
                        fi

TOUCH                 = @touch $@; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed"; \
                        else \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed"; \
                        fi; \
                        echo ; \
                        $(call draw_line,$(PKG_NAME),2); \
                        echo

TUXBOX_CUSTOMIZE = [ -x $(CUSTOM_DIR)/$(notdir $@)-local.sh ] && \
	KERNEL_VER=$(KERNEL_VER) && \
	BOXTYPE=$(BOXTYPE) && \
	$(CUSTOM_DIR)/$(notdir $@)-local.sh \
	$(RELEASE_DIR) \
	$(TARGET_DIR) \
	$(BASE_DIR) \
	$(SOURCE_DIR) \
	$(FLASH_DIR) \
	$(BOXTYPE) \
	$(FLAVOUR) \
	$(RELEASE_IMAGE_DIR) \
	|| true

#
#
#
CONFIGURE_OPTS = \
	--build=$(BUILD) \
	--host=$(TARGET) \

BUILDENV := \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)"

CONFIGURE = \
	test -f ./configure || ./autogen.sh $(SILENT_OPT) && \
	$(BUILDENV) \
	./configure $(SILENT_OPT) $(CONFIGURE_OPTS)

CONFIGURE_TOOLS = \
	./autogen.sh $(SILENT_OPT) && \
	$(BUILDENV) \
	./configure $(SILENT_OPT) $(CONFIGURE_OPTS)

MAKE_OPTS := \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	ARCH=sh \
	CROSS_COMPILE=$(TARGET)-

CMAKE_OPTS := \
	-DBUILD_SHARED_LIBS=ON \
	-DENABLE_STATIC=OFF \
	-DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_SYSTEM_PROCESSOR="arm" \
	-DCMAKE_INSTALL_DOCDIR=/.remove \
	-DCMAKE_INSTALL_MANDIR=/.remove \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_DEFAULT_LIBDIR=lib \
	-DCMAKE_INCLUDE_PATH="$(TARGET_DIR)/usr/include" \
	-DCMAKE_PREFIX_PATH=$(TARGET_DIR)/usr \
	-DCMAKE_C_COMPILER=$(TARGET)-gcc \
	-DCMAKE_CXX_COMPILER=$(TARGET)-g++ \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS)" \
	-DCMAKE_LINKER="$(TARGET)-ld" \
	-DCMAKE_AR="$(TARGET)-ar" \
	-DCMAKE_NM="$(TARGET)-nm" \
	-DCMAKE_OBJDUMP="$(TARGET)-objdump" \
	-DCMAKE_RANLIB="$(TARGET)-ranlib" \
	-DCMAKE_STRIP="$(TARGET)-strip"

CMAKE := \
	rm -f CMakeCache.txt; \
	cmake $(SILENT_OPT) --no-warn-unused-cli $(CMAKE_OPTS)
#
# image
#
ifeq ($(IMAGE), neutrino)
BUILD_CONFIG       = build-neutrino
else ifeq ($(IMAGE), neutrino-wlandriver)
BUILD_CONFIG       = build-neutrino
WLANDRIVER         = WLANDRIVER=wlandriver
else
BUILD_CONFIG       = build-neutrino
endif

#
DRIVER_PLATFORM   := $(WLANDRIVER)

#
ifeq ($(BOXTYPE), ufs910)
KERNEL_PATCHES_24  = $(UFS910_PATCHES_24)
DRIVER_PLATFORM   += UFS910=ufs910
endif
ifeq ($(BOXTYPE), ufs912)
KERNEL_PATCHES_24  = $(UFS912_PATCHES_24)
DRIVER_PLATFORM   += UFS912=ufs912
endif
ifeq ($(BOXTYPE), ufs913)
KERNEL_PATCHES_24  = $(UFS913_PATCHES_24)
DRIVER_PLATFORM   += UFS913=ufs913
endif
ifeq ($(BOXTYPE), ufs922)
KERNEL_PATCHES_24  = $(UFS922_PATCHES_24)
DRIVER_PLATFORM   += UFS922=ufs922
endif
ifeq ($(BOXTYPE), ufc960)
KERNEL_PATCHES_24  = $(UFC960_PATCHES_24)
DRIVER_PLATFORM   += UFC960=ufc960
endif
ifeq ($(BOXTYPE), tf7700)
KERNEL_PATCHES_24  = $(TF7700_PATCHES_24)
DRIVER_PLATFORM   += TF7700=tf7700
endif
ifeq ($(BOXTYPE), hl101)
KERNEL_PATCHES_24  = $(HL101_PATCHES_24)
DRIVER_PLATFORM   += HL101=hl101
endif
ifeq ($(BOXTYPE), spark)
KERNEL_PATCHES_24  = $(SPARK_PATCHES_24)
DRIVER_PLATFORM   += SPARK=spark
endif
ifeq ($(BOXTYPE), spark7162)
KERNEL_PATCHES_24  = $(SPARK7162_PATCHES_24)
DRIVER_PLATFORM   += SPARK7162=spark7162
endif
ifeq ($(BOXTYPE), fortis_hdbox)
KERNEL_PATCHES_24  = $(FORTIS_HDBOX_PATCHES_24)
DRIVER_PLATFORM   += FORTIS_HDBOX=fortis_hdbox
endif
ifeq ($(BOXTYPE), hs7110)
KERNEL_PATCHES_24  = $(HS7110_PATCHES_24)
DRIVER_PLATFORM   += HS7110=hs7110
endif
ifeq ($(BOXTYPE), hs7119)
KERNEL_PATCHES_24  = $(HS7119_PATCHES_24)
DRIVER_PLATFORM   += HS7119=hs7119
endif
ifeq ($(BOXTYPE), hs7420)
KERNEL_PATCHES_24  = $(HS7420_PATCHES_24)
DRIVER_PLATFORM   += HS7420=hs7420
endif
ifeq ($(BOXTYPE), hs7429)
KERNEL_PATCHES_24  = $(HS7429_PATCHES_24)
DRIVER_PLATFORM   += HS7429=hs7429
endif
ifeq ($(BOXTYPE), hs7810a)
KERNEL_PATCHES_24  = $(HS7810A_PATCHES_24)
DRIVER_PLATFORM   += HS7810A=hs7810a
endif
ifeq ($(BOXTYPE), hs7819)
KERNEL_PATCHES_24  = $(HS7819_PATCHES_24)
DRIVER_PLATFORM   += HS7819=hs7819
endif
ifeq ($(BOXTYPE), atemio520)
KERNEL_PATCHES_24  = $(ATEMIO520_PATCHES_24)
DRIVER_PLATFORM   += ATEMIO520=atemio520
endif
ifeq ($(BOXTYPE), atemio530)
KERNEL_PATCHES_24  = $(ATEMIO530_PATCHES_24)
DRIVER_PLATFORM   += ATEMIO530=atemio530
endif
ifeq ($(BOXTYPE), atevio7500)
KERNEL_PATCHES_24  = $(ATEVIO7500_PATCHES_24)
DRIVER_PLATFORM   += ATEVIO7500=atevio7500
endif
ifeq ($(BOXTYPE), octagon1008)
KERNEL_PATCHES_24  = $(OCTAGON1008_PATCHES_24)
DRIVER_PLATFORM   += OCTAGON1008=octagon1008
endif
ifeq ($(BOXTYPE), adb_box)
KERNEL_PATCHES_24  = $(ADB_BOX_PATCHES_24)
DRIVER_PLATFORM   += ADB_BOX=adb_box
endif
ifeq ($(BOXTYPE), ipbox55)
KERNEL_PATCHES_24  = $(IPBOX55_PATCHES_24)
DRIVER_PLATFORM   += IPBOX55=ipbox55
endif
ifeq ($(BOXTYPE), ipbox99)
KERNEL_PATCHES_24  = $(IPBOX99_PATCHES_24)
endif
ifeq ($(BOXTYPE), ipbox9900)
KERNEL_PATCHES_24  = $(IPBOX9900_PATCHES_24)
DRIVER_PLATFORM   += IPBOX9900=ipbox9900
endif
ifeq ($(BOXTYPE), cuberevo)
KERNEL_PATCHES_24  = $(CUBEREVO_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO=cuberevo
endif
ifeq ($(BOXTYPE), cuberevo_mini)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_MINI=cuberevo_mini
endif
ifeq ($(BOXTYPE), cuberevo_mini2)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI2_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_MINI2=cuberevo_mini2
endif
ifeq ($(BOXTYPE), cuberevo_mini_fta)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI_FTA_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_MINI_FTA=cuberevo_mini_fta
endif
ifeq ($(BOXTYPE), cuberevo_250hd)
KERNEL_PATCHES_24  = $(CUBEREVO_250HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_250HD=cuberevo_250hd
endif
ifeq ($(BOXTYPE), cuberevo_2000hd)
KERNEL_PATCHES_24  = $(CUBEREVO_2000HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_2000HD=cuberevo_2000hd
endif
ifeq ($(BOXTYPE), cuberevo_3000hd)
KERNEL_PATCHES_24  = $(CUBEREVO_3000HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_3000HD=cuberevo_3000hd
endif
ifeq ($(BOXTYPE), cuberevo_9500hd)
KERNEL_PATCHES_24  = $(CUBEREVO_9500HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_9500HD=cuberevo_9500hd
endif
ifeq ($(BOXTYPE), vitamin_hd5000)
KERNEL_PATCHES_24  = $(VITAMIN_HD5000_PATCHES_24)
DRIVER_PLATFORM   += VITAMIN_HD5000=vitamin_hd5000
endif
ifeq ($(BOXTYPE), sagemcom88)
KERNEL_PATCHES_24  = $(SAGEMCOM88_PATCHES_24)
DRIVER_PLATFORM   += SAGEMCOM88=sagemcom88
endif
ifeq ($(BOXTYPE), arivalink200)
KERNEL_PATCHES_24  = $(ARIVALINK200_PATCHES_24)
DRIVER_PLATFORM   += ARIVALINK200=arivalink200
endif
ifeq ($(BOXTYPE), pace7241)
KERNEL_PATCHES_24  = $(PACE7241_PATCHES_24)
DRIVER_PLATFORM   += PACE7241=pace7241
endif
