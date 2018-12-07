include $(THEOS)/makefiles/common.mk

TWEAK_NAME = awemeusercrawler
awemeusercrawler_FILES = Tweak.xm MessageSendController.m VKMsgSend.m
awemeusercrawler_CFLAGS = -fobjc-arc
awemeusercrawler_LDFLAGS = -lhidsupport
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Aweme"
