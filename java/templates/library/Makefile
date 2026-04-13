##############################################
# Simple java build makefile.
##############################################

# Full path to compiler to use
JAVACC = $(JAVA_HOME)/bin/javac

# Source and target file format
TARGET = 1.3

# To be adapted and will passed to java compiler
JFLAGS = -g -bootclasspath C:/PortableApps/Java/libs/cldc_1.1.jar

# A whitespace separated list of source file directories
SRC = common-io/src/main/java/com/optimasc/io/*.java common-archive/src/main/java/com/optimasc/archive/*.java \
 common-charsets/src/main/java/com/optimasc/nio/charset/*.java common-text/src/main/java/com/optimasc/text/*.java \
 common-util/src/main/java/com/optimasc/locale/*.java common-util/src/main/java/com/optimasc/utils/*.java \
 common-util/src/main/java/com/optimasc/xml/*.java common-util-error/src/main/java/com/optimasc/utils/error/*.java
OUT=$(SRC:.java=.class) 
RM = rm -f

main:
	$(JAVACC) -target $(TARGET) -source $(TARGET) $(JFLAGS) $(SRC)

clean:
	$(RM) $(OUT)
	