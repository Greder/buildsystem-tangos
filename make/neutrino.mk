# makefile to build NEUTRINO

# -----------------------------------------------------------------------------
N_CONFIG_KEYS ?=

OMDB_API_KEY ?=
ifneq ($(strip $(OMDB_API_KEY)),)
N_CONFIG_KEYS += \
	--with-omdb-api-key="$(OMDB_API_KEY)" \
	--disable-omdb-key-manage
endif

TMDB_DEV_KEY ?=
ifneq ($(strip $(TMDB_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-tmdb-dev-key="$(TMDB_DEV_KEY)" \
	--disable-tmdb-key-manage
endif

YOUTUBE_DEV_KEY ?=
ifneq ($(strip $(YOUTUBE_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-youtube-dev-key="$(YOUTUBE_DEV_KEY)" \
	--disable-youtube-key-manage
endif

SHOUTCAST_DEV_KEY ?=
ifneq ($(strip $(SHOUTCAST_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-shoutcast-dev-key="$(SHOUTCAST_DEV_KEY)" \
	--disable-shoutcast-key-manage
endif

WEATHER_DEV_KEY ?=
ifneq ($(strip $(WEATHER_DEV_KEY)),)
N_CONFIG_KEYS += \
	--with-weather-dev-key="$(WEATHER_DEV_KEY)" \
	--disable-weather-key-manage
endif

# -----------------------------------------------------------------------------

COMMON_DEPS  = $(D)/bootstrap
COMMON_DEPS += $(KERNEL)
COMMON_DEPS += $(D)/system-tools
COMMON_DEPS += $(D)/ncurses
COMMON_DEPS += $(D)/libcurl
COMMON_DEPS += $(D)/libpng
COMMON_DEPS += $(D)/libjpeg
COMMON_DEPS += $(D)/giflib
COMMON_DEPS += $(D)/alsa_utils
COMMON_DEPS += $(D)/freetype
COMMON_DEPS += $(D)/zlib
COMMON_DEPS += $(D)/ffmpeg
COMMON_DEPS += $(D)/libopenthreads
COMMON_DEPS += $(D)/libfribidi
COMMON_DEPS += $(D)/lua
COMMON_DEPS += $(D)/luaexpat
COMMON_DEPS += $(D)/luacurl
COMMON_DEPS += $(D)/luasocket
COMMON_DEPS += $(D)/luafeedparser
COMMON_DEPS += $(D)/luasoap
COMMON_DEPS += $(D)/luajson
COMMON_DEPS += $(D)/ntfs_3g
COMMON_DEPS += $(D)/gptfdisk
COMMON_DEPS += $(D)/mc
COMMON_DEPS += $(D)/samba
COMMON_DEPS += $(D)/rsync
COMMON_DEPS += $(D)/links
COMMON_DEPS += $(D)/dropbearmulti
COMMON_DEPS += $(D)/djmount
#COMMON_DEPS +=  $(D)/minidlna
#COMMON_DEPS +=  $(D)/minisatip

# -----------------------------------------------------------------------------

LIBSTB_HAL_DEPS = $(COMMON_DEPS)

# -----------------------------------------------------------------------------

NEUTRINO_DEPS  = $(COMMON_DEPS)
NEUTRINO_DEPS += $(D)/libsigc
NEUTRINO_DEPS += $(D)/libdvbsi
NEUTRINO_DEPS += $(D)/libusb
NEUTRINO_DEPS += $(D)/pugixml

NEUTRINO_DEPS += $(D)/neutrino-plugins
NEUTRINO_DEPS += $(D)/neutrino-plugin-scripts-lua
NEUTRINO_DEPS += $(D)/neutrino-plugin-mediathek
NEUTRINO_DEPS += $(D)/neutrino-plugin-xupnpd
NEUTRINO_DEPS += $(D)/neutrino-plugin-channellogos
NEUTRINO_DEPS += $(D)/neutrino-plugin-iptvplayer
NEUTRINO_DEPS += $(D)/neutrino-plugin-settings-update
#NEUTRINO_DEPS += $(D)/neutrino-plugin-spiegel-tv
#NEUTRINO_DEPS += $(D)/neutrino-plugin-tierwelt-tv
NEUTRINO_DEPS += $(D)/neutrino-plugin-mtv
NEUTRINO_DEPS += $(D)/neutrino-plugin-custom
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_PLUGINS)

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)

ifeq ($(IMAGE), neutrino-wlandriver)
NEUTRINO_DEPS += $(D)/wpa_supplicant
NEUTRINO_DEPS += $(D)/wireless_tools
endif

N_CFLAGS       = -Wall -W -Wshadow -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing
N_CFLAGS      += -funsigned-char
N_CFLAGS      += -ffunction-sections
N_CFLAGS      += -fdata-sections
N_CFLAGS      += -Wno-psabi
N_CFLAGS      += -L/usr/lib/x86_64-linux-gn
#N_CFLAGS      += -Wno-deprecated-declarations
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_INCLUDE_DIR)
N_CPPFLAGS    += -ffunction-sections -fdata-sections
N_CPPFLAGS    += -std=c++11
#N_CPPFLAGS    = /usr/include/lua5.2

ifeq ($(BOXARCH), arm)
N_CPPFLAGS    += -I$(CROSS_DIR)/$(TARGET)/sys-root/usr/include
endif

LH_CONFIG_OPTS = $(LOCAL_LIBHAL_BUILD_OPTIONS)

ifeq ($(FLAVOUR), $(filter $(FLAVOUR), NI TUXBOX))
N_CONFIG_OPTS += --with-boxtype=armbox
N_CONFIG_OPTS += --with-boxmodel=$(BOXTYPE)
LH_CONFIG_OPTS += --with-boxtype=armbox
LH_CONFIG_OPTS += --with-boxmodel=$(BOXTYPE)
else
N_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)
LH_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)
endif

N_CONFIG_OPTS += --enable-ffmpegdec
N_CONFIG_OPTS += --enable-freesatepg
N_CONFIG_OPTS += --enable-fribidi
N_CONFIG_OPTS += --disable-upnp
#N_CONFIG_OPTS += --enable-pip
#N_CONFIG_OPTS += --enable-dynamicdemux
#N_CONFIG_OPTS += --enable-reschange
#N_CONFIG_OPTS += --disable-webif
#N_CONFIG_OPTS += --disable-tangos

N_CONFIG_OPTS += \
	--with-libdir=/usr/lib \
	--with-datadir=/usr/share/tuxbox \
	--with-fontdir=/usr/share/fonts \
	--with-fontdir_var=/var/tuxbox/fonts \
	--with-configdir=/var/tuxbox/config \
	--with-gamesdir=/var/tuxbox/games \
	--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
	--with-iconsdir_var=/var/tuxbox/icons \
	--with-localedir=/usr/share/tuxbox/neutrino/locale \
	--with-localedir_var=/var/tuxbox/locale \
	--with-plugindir=/usr/share/tuxbox/neutrino/plugins \
	--with-plugindir_var=/var/tuxbox/plugins \
	--with-lcd4liconsdir_var=/var/tuxbox/lcd/icons \
	--with-luaplugindir=/var/tuxbox/plugins \
	--with-public_httpddir=/var/tuxbox/httpd \
	--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
	--with-themesdir=/usr/share/tuxbox/neutrino/themes \
	--with-themesdir_var=/var/tuxbox/themes \
	--with-webtvdir=/usr/share/tuxbox/neutrino/webtv \
	--with-webtvdir_var=/var/tuxbox/webtv \
	--with-webradiodir=/usr/share/tuxbox/neutrino/webradio \
	--with-webradiodir_var=/var/tuxbox/webradio \
	--with-controldir=/usr/share/tuxbox/neutrino/control \
	--with-controldir_var=/var/tuxbox/control

ifeq ($(EXTERNAL_LCD), externallcd)
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
endif

ifeq ($(EXTERNAL_LCD), lcd4linux)
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/lcd4linux
NEUTRINO_DEPS += $(D)/neutrino-plugin-l4l-skins
endif

ifeq ($(EXTERNAL_LCD), both)
N_CONFIG_OPTS += --enable-graphlcd
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/graphlcd
NEUTRINO_DEPS += $(D)/lcd4linux
NEUTRINO_DEPS += $(D)/neutrino-plugin-l4l-skins
endif
# -----------------------------------------------------------------------------

ifeq ($(MEDIAFW), gstreamer)
NEUTRINO_DEPS  += $(D)/gst_plugins_dvbmediasink
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
LH_CONFIG_OPTS += --enable-gstreamer_10=yes
endif

# -----------------------------------------------------------------------------

N_OBJDIR = $(BUILD_TMP)/$(NEUTRINO)
LH_OBJDIR = $(BUILD_TMP)/$(LIBSTB_HAL)

ifeq ($(FLAVOUR), neutrino-max)
GIT_URL     ?= https://github.com/MaxWiesel
NEUTRINO_MP  = neutrino-mp-max
LIBSTB_HAL   = libstb-hal-max
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MP_MAX_PATCHES)
HAL_PATCHES  = $(NEUTRINO_MP_LIBSTB_MAX_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-ni)
GIT_URL     ?= https://github.com/neutrino-images
NEUTRINO_MP  = ni-neutrino
LIBSTB_HAL   = ni-libstb-hal
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MP_NI_PATCHES)
HAL_PATCHES  = $(NEUTRINO_MP_LIBSTB_NI_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-tangos)
GIT_URL     ?= https://github.com/TangoCash
NEUTRINO  = neutrino-tangos
LIBSTB_HAL   = libstb-hal-tangos
NMP_BRANCH  ?= master
NMP_CHECKOUT  ?= f5f2e6e066e99323695989f5cdf606b67256481d
HAL_BRANCH  ?= master
HAL_CHECKOUT  ?= 8419f846e155aafc65120522974e9ee491f45428
#NMP_PATCHES  = $(PATCHES)/build-neutrino/neutrino-tangos.patch
HAL_PATCHES  = $(PATCHES)/build-neutrino/libstb-hal-tangos.patch
else ifeq  ($(FLAVOUR), neutrino-ddt)
GIT_URL     ?= https://github.com/Duckbox-Developers
NEUTRINO  = neutrino-mp-ddt
LIBSTB_HAL   = libstb-hal-ddt
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MP_DDT_PATCHES)
HAL_PATCHES  = $(NEUTRINO_MP_LIBSTB_DDT_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-tuxbox)
GIT_URL     ?= https://github.com/tuxbox-neutrino
NEUTRINO_MP  = gui-neutrino
LIBSTB_HAL   = library-stb-hal
NMP_BRANCH  ?= master
HAL_BRANCH  ?= mpx
NMP_PATCHES  = $(NEUTRINO_MP_TUX_PATCHES)
HAL_PATCHES  = $(NEUTRINO_MP_LIBSTB_TUX_PATCHES)
endif

# -----------------------------------------------------------------------------

.version: $(TARGET_DIR)/.version
$(TARGET_DIR)/.version:
	echo "distro=$(FLAVOUR)" > $@
	echo "imagename=`sed -n 's/\#define PACKAGE_NAME "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
	echo "imageversion=`sed -n 's/\#define PACKAGE_VERSION "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
	echo "homepage=https://github.com/Duckbox-Developers" >> $@
	echo "creator=$(MAINTAINER)" >> $@
	echo "docs=https://github.com/Duckbox-Developers" >> $@
	echo "forum=https://github.com/Duckbox-Developers/neutrino-mp-ddt" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "builddate="`date` >> $@
	echo "git=BS-rev$(BS_REV)_HAL-rev$(HAL_REV)_NMP-rev$(NMP_REV)" >> $@
	echo "imagedir=$(BOXTYPE)" >> $@

# -----------------------------------------------------------------------------

e2-multiboot:
	touch $(TARGET_DIR)/usr/bin/enigma2
	#
	echo -e "$(FLAVOUR) `sed -n 's/\#define PACKAGE_VERSION "//p' $(N_OBJDIR)/config.h | sed 's/"//'` \\\n \\\l\n" > $(TARGET_DIR)/etc/issue
	#
	touch $(TARGET_DIR)/var/lib/opkg/status 
	#
	cp -a $(TARGET_DIR)/.version $(TARGET_DIR)/etc/image-version

# -----------------------------------------------------------------------------

version.h: $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
$(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h:
	@rm -f $@
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/$(LIBSTB_HAL); then \
		echo '#define VCS "BS-rev$(BS_REV)_HAL-rev$(HAL_REV)_NMP-rev$(NMP_REV)"' >> $@; \
	fi

# -----------------------------------------------------------------------------

$(D)/libstb-hal.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).org
	rm -rf $(LH_OBJDIR)
	test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] && \
	(cd $(ARCHIVE)/$(LIBSTB_HAL).git; git pull;); \
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] || \
	git clone $(GIT_URL)/$(LIBSTB_HAL).git $(ARCHIVE)/$(LIBSTB_HAL).git; \
	cp -ra $(ARCHIVE)/$(LIBSTB_HAL).git $(SOURCE_DIR)/$(LIBSTB_HAL);\
	(cd $(SOURCE_DIR)/$(LIBSTB_HAL); git checkout $(HAL_CHECKOUT);); \
	cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).org
	set -e; cd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		$(call apply_patches, $(HAL_PATCHES))
	@touch $@

$(D)/libstb-hal.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR)
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared=no \
			\
			--with-target=cdk \
			--with-targetprefix=/usr \
			--with-boxtype=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
#	@touch $@

$(D)/libstb-hal.do_compile: $(D)/libstb-hal.config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal: $(D)/libstb-hal.do_prepare $(D)/libstb-hal.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libstb-hal.la
	$(TOUCH)

libstb-hal-clean:
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal*

# -----------------------------------------------------------------------------

$(D)/neutrino.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).org
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] && \
	(cd $(ARCHIVE)/$(NEUTRINO).git; git pull;); \
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] || \
	git clone $(GIT_URL)/$(NEUTRINO).git $(ARCHIVE)/$(NEUTRINO).git; \
	cp -ra $(ARCHIVE)/$(NEUTRINO).git $(SOURCE_DIR)/$(NEUTRINO); \
	(cd $(SOURCE_DIR)/$(NEUTRINO); git checkout $(MINUS_Q) $(NMP_CHECKOUT);); \
	cp -ra $(SOURCE_DIR)/$(NEUTRINO) $(SOURCE_DIR)/$(NEUTRINO).org
	set -e; cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(call apply_patches, $(NMP_PATCHES))
	@touch $@

$(D)/neutrino.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NEUTRINO)/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr/local \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--enable-giflib \
			--enable-lua \
			--enable-pugixml \
			\
			$(N_CONFIG_KEYS) \
			\
			$(N_CONFIG_OPTS) \
			\
			--with-tremor \
			--with-stb-hal-includes=$(SOURCE_DIR)/$(LIBSTB_HAL)/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
		+make $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
#	@touch $@

$(D)/neutrino.do_compile:
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

mp \
neutrino: $(D)/neutrino
$(D)/neutrino: $(D)/neutrino.do_prepare $(D)/neutrino.config.status $(D)/neutrino.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	make .version
	make e2-multiboot
	$(TOUCH)
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

mp-clean \
neutrino-clean:
	rm -f $(D)/neutrino
	rm -f $(D)/neutrino.config.status
	rm -f $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mp-distclean \
neutrino-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino*

# -----------------------------------------------------------------------------
#
# neutrino-hd2
#
ifeq ($(BOXTYPE), spark)
NHD2_OPTS = --enable-4digits
else ifeq ($(BOXTYPE), spark7162)
NHD2_OPTS =
else
NHD2_OPTS = --enable-ci
endif

NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2.do_prepare: | $(NEUTRINO_DEPS) $(D)/libid3tag $(D)/libmad $(D)/flac
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-hd2
	rm -rf $(SOURCE_DIR)/neutrino-hd2.org
	rm -rf $(SOURCE_DIR)/neutrino-hd2.git
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] && \
	(cd $(ARCHIVE)/neutrino-hd2.git; git pull;); \
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] || \
	git clone https://github.com/mohousch/neutrinohd2.git $(ARCHIVE)/neutrino-hd2.git; \
	cp -ra $(ARCHIVE)/neutrino-hd2.git $(SOURCE_DIR)/neutrino-hd2.git; \
	ln -s $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2;\
	cp -ra $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2.org
	set -e; cd $(SOURCE_DIR)/neutrino-hd2; \
		$(call apply_patches, $(NEUTRINO_HD2_PATCHES))
	@touch $@

$(D)/neutrino-hd2.config.status:
	cd $(SOURCE_DIR)/neutrino-hd2; \
		./autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		./configure $(SILENT_OPT)\
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-silent-rules \
			--with-boxtype=$(BOXTYPE) \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-isocodesdir=/usr/local/share/iso-codes \
			$(NHD2_OPTS) \
			--enable-scart \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2.do_compile: $(D)/neutrino-hd2.config.status
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) all
	@touch $@

neutrino-hd2: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/.version
	touch $(D)/$(notdir $@)
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

nhd2 \
neutrino-hd2-plugins: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/.version
	touch $(D)/$(notdir $@)
	make neutrino-hd2-plugins.build
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

nhd2-clean \
neutrino-hd2-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2
	rm -f $(D)/neutrino-hd2.config.status
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) clean

nhd2-distclean \
neutrino-hd2-distclean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2*
	rm -f $(D)/neutrino-hd2-plugins*

# -----------------------------------------------------------------------------
neutrino-cdkroot-clean:
	[ -e $(TARGET_DIR)/usr/local/bin ] && cd $(TARGET_DIR)/usr/local/bin && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/local/share/iso-codes ] && cd $(TARGET_DIR)/usr/local/share/iso-codes && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/tuxbox/neutrino ] && cd $(TARGET_DIR)/usr/share/tuxbox/neutrino && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/fonts ] && cd $(TARGET_DIR)/usr/share/fonts && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/var/tuxbox ] && cd $(TARGET_DIR)/var/tuxbox && find -name '*' -delete || true

dual:
	make nhd2
	make neutrino-cdkroot-clean
	make mp

dual-clean:
	make nhd2-clean
	make mp-clean

dual-distclean:
	make nhd2-distclean
	make mp-distclean

# -----------------------------------------------------------------------------

PHONY += $(TARGET_DIR)/.version
PHONY += $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
