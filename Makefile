SHELL = /bin/sh


prefix=/usr/local
exec_prefix=${prefix}
MANDIR=${prefix}/man
BINDIR=${exec_prefix}/bin
SBINDIR=${exec_prefix}/sbin

# For radmind tools
VARDIR=/var/radmind

# For server
CONFIGFILE=${VARDIR}/config
TRANSCRIPTDIR=${VARDIR}/transcript

# For client
COMMANDFILE=${VARDIR}/client/command.K
GNU_DIFF=/usr/local/gnu/bin/diff
RADMIND_HOST=radmind

RADMINDSYSLOG=LOG_LOCAL7

CWARN=	-Wall -Wmissing-prototypes -Wconversion -Werror
OPENSSL=	/usr/local/openssl
CC = gcc
LDFLAGS = 
LIBS = -lsocket -lnsl 
INSTALL = ./install-sh -c

INCPATH=	-I${OPENSSL}/include -Ilibsnet
CFLAGS=		${CWARN} ${INCPATH} -g -O2
LDFLAGS=	-L${OPENSSL}/lib -Llibsnet ${LIBS} -lsnet -lcrypto

BINTARGETS=     fsdiff ktcheck lapply lcksum lcreate lmerge lfdiff twhich
MAN1TARGETS=    fsdiff.1 ktcheck.1 lapply.1 lcksum.1 lcreate.1 lfdiff.1 \
                lmerge.1 twhich.1
MAN5TARGETS= 	applefile.5
MAN8TARGETS=	radmind.8
MANTARGETS=	${MAN1TARGETS} ${MAN5TARGETS} ${MAN8TARGETS}
TARGETS=        radmind ${BINTARGETS}

RADMIND_OBJ=    version.o daemon.o command.o argcargv.o code.o \
                cksum.o base64.o mkdirs.o applefile.o connect.o

FSDIFF_OBJ=     version.o fsdiff.o argcargv.o transcript.o llist.o code.o \
                hardlink.o cksum.o base64.o pathcmp.o radstat.o applefile.o \
                connect.o

KTCHECK_OBJ=    version.o ktcheck.o argcargv.o retr.o base64.o code.o \
                cksum.o list.o connect.o applefile.o

LAPPLY_OBJ=     version.o lapply.o argcargv.o code.o base64.o retr.o \
                radstat.o update.o cksum.o connect.o pathcmp.o \
                applefile.o

LCREATE_OBJ=    version.o lcreate.o argcargv.o code.o connect.o \
                stor.o applefile.o base64.o cksum.o radstat.o

LCKSUM_OBJ=     version.o lcksum.o argcargv.o cksum.o base64.o code.o \
                pathcmp.o applefile.o connect.o

LMERGE_OBJ=     version.o lmerge.o argcargv.o code.o pathcmp.o mkdirs.o

LFDIFF_OBJ=     version.o lfdiff.o argcargv.o connect.o retr.o cksum.o \
                base64.o applefile.o code.o

TWHICH_OBJ=     version.o argcargv.o code.o twhich.o pathcmp.o

all : ${TARGETS}

version.o : version.c
	${CC} ${CFLAGS} \
		-DVERSION=\"`cat VERSION`\" \
		-c version.c

daemon.o : daemon.c
	${CC} ${CFLAGS} \
		-D_PATH_RADMIND=\"${VARDIR}\" -DLOG_RADMIND=${RADMINDSYSLOG} \
		-c daemon.c

command.o : command.c
	${CC} ${CFLAGS} \
		-D_PATH_CONFIG=\"${CONFIGFILE}\" \
		-D_PATH_TRANSCRIPTS=\"${TRANSCRIPTDIR}\" \
		-c command.c

fsdiff.o : fsdiff.c
	${CC} ${CFLAGS} \
		-D_RADMIND_COMMANDFILE=\"${COMMANDFILE}\" \
		-c fsdiff.c

lfdiff.o : lfdiff.c
	${CC} ${CFLAGS} \
		-D_PATH_GNU_DIFF=\"${GNU_DIFF}\" \
		-D_RADMIND_HOST=\"${RADMIND_HOST}\" \
		-c lfdiff.c

ktcheck.o : ktcheck.c
	${CC} ${CFLAGS} \
		-D_RADMIND_HOST=\"${RADMIND_HOST}\" \
		-D_RADMIND_COMMANDFILE=\"${COMMANDFILE}\" \
		-c ktcheck.c

lapply.o : lapply.c
	${CC} ${CFLAGS} \
		-D_RADMIND_HOST=\"${RADMIND_HOST}\" \
		-c lapply.c

lcreate.o : lcreate.c
	${CC} ${CFLAGS} \
		-D_RADMIND_HOST=\"${RADMIND_HOST}\" \
		-c lcreate.c

twhich.o : twhich.c
	${CC} ${CFLAGS} \
		-D_RADMIND_COMMANDFILE=\"${COMMANDFILE}\" \
		-c twhich.c

radmind : libsnet/libsnet.a ${RADMIND_OBJ} Makefile
	${CC} ${CFLAGS} -o radmind ${RADMIND_OBJ} ${LDFLAGS}

fsdiff : ${FSDIFF_OBJ}
	${CC} -o fsdiff ${FSDIFF_OBJ} ${LDFLAGS}

ktcheck: ${KTCHECK_OBJ}
	${CC} -o ktcheck ${KTCHECK_OBJ} ${LDFLAGS}

lapply: ${LAPPLY_OBJ}
	${CC} -o lapply ${LAPPLY_OBJ} ${LDFLAGS}

lcksum: ${LCKSUM_OBJ}
	${CC} -o lcksum ${LCKSUM_OBJ} ${LDFLAGS}

lcreate: ${LCREATE_OBJ}
	${CC} -o lcreate ${LCREATE_OBJ} ${LDFLAGS}

lmerge: ${LMERGE_OBJ}
	${CC} -o lmerge ${LMERGE_OBJ} ${LDFLAGS}

lfdiff: ${LFDIFF_OBJ}
	${CC} -o lfdiff ${LFDIFF_OBJ} ${LDFLAGS}

twhich: ${TWHICH_OBJ}
	${CC} -o twhich ${TWHICH_OBJ} ${LDFLAGS}


FRC :

libsnet/libsnet.a : FRC
	cd libsnet; ${MAKE} ${MFLAGS} CC=${CC}

VERSION=`date +%Y%m%d`
DISTDIR=../radmind-${VERSION}

dist   : clean
	mkdir ${DISTDIR}
	tar chfFFX - EXCLUDE . | ( cd ${DISTDIR}; tar xvf - )
	chmod +w ${DISTDIR}/Makefile
	echo ${VERSION} > ${DISTDIR}/VERSION

.PHONY : man
man :
	-mkdir tmp
	-mkdir tmp/man
	pwd
	for i in ${MANTARGETS}; do \
	    sed -e 's@_PATH_RADMIND@${VARDIR}@g'  \
		-e 's@_RADMIND_COMMANDFILE@${COMMANDFILE}@g' \
		-e 's@_RADMIND_HOST@${RADMIND_HOST}@g' \
		$$i > tmp/man/$$i; \
	done

install	: all man
	-mkdir -p ${DESTDIR}
	-mkdir -p ${SBINDIR}
	${INSTALL} -m 0755 -c radmind ${SBINDIR}/
	-mkdir -p ${BINDIR}
	for i in ${BINTARGETS}; do \
	    ${INSTALL} -m 0755 -c $$i ${BINDIR}/; \
	done
	-mkdir -p ${MANDIR}
	-mkdir ${MANDIR}/man1
	for i in ${MAN1TARGETS}; do \
	    ${INSTALL} -m 0644 -c tmp/man/$$i ${MANDIR}/man1/; \
	done
	-mkdir ${MANDIR}/man5
	for i in ${MAN5TARGETS}; do \
	    ${INSTALL} -m 0644 -c tmp/man/$$i ${MANDIR}/man5/; \
	done
	-mkdir ${MANDIR}/man8
	 for i in ${MAN8TARGETS}; do \
	    ${INSTALL} -m 0644 -c tmp/man/$$i ${MANDIR}/man8/; \
	done

MPKGDIR=${DISTDIR}-MPKG
CLIENTBINPKGDIR=${MPKGDIR}/client-bin
CLIENTMANPKGDIR=${MPKGDIR}/client-man
CLIENTVARPKGDIR=${MPKGDIR}/client-var
SERVERSTARTUPPKGDIR=${MPKGDIR}/server-startup
SERVERSBINPKGDIR=${MPKGDIR}/server-sbin
SERVERMANPKGDIR=${MPKGDIR}/server-man
INFOLIST=	$(wildcard OS_X/*.info)	

info :
	-mkdir tmp
	-mkdir tmp/OS_X
	for i in ${INFOLIST}; do \
	    sed -e 's@_VERSION_RADMIND@${VERSION}@g'  \
		$$i > tmp/$$i; \
	done

package : all man info
	# Create server package #
	mkdir -p -m 0755 ${SERVERSBINPKGDIR}
	${INSTALL} -o root -g wheel -m 0555 -c radmind ${SERVERSBINPKGDIR}
	mkdir -m 0755 ${SERVERSTARTUPPKGDIR} 
	${INSTALL} -o root -g wheel -m 0755 -c OS_X/RadmindServer \
	    ${SERVERSTARTUPPKGDIR}
	${INSTALL} -o root -g wheel -m 0644 -c OS_X/StartupParameters.plist \
	    ${SERVERSTARTUPPKGDIR}
	mkdir -p -m 0755 ${SERVERMANPKGDIR}/man8
	for i in ${MAN8TARGETS}; do \
	    ${INSTALL} -o root -g wheel -m 0444 -c tmp/man/$$i \
		${SERVERMANPKGDIR}/man8/; \
	done

	# Create client package #
	mkdir -p -m 0755 ${CLIENTBINPKGDIR}
	for i in ${BINTARGETS}; do \
	    ${INSTALL} -o root -g wheel -m 0555 -c $$i \
		${CLIENTBINPKGDIR}/; \
	done
	mkdir -p -m 0755 ${CLIENTMANPKGDIR}/man1
	for i in ${MAN1TARGETS}; do \
	    ${INSTALL} -o root -g wheel -m 0444 -c tmp/man/$$i \
		${CLIENTMANPKGDIR}/man1/; \
	done 
	mkdir -p -m 0755 ${CLIENTMANPKGDIR}/man5
	for i in ${MAN5TARGETS}; do \
	    ${INSTALL} -o root -g wheel -m 0444 -c tmp/man/$$i \
		${CLIENTMANPKGDIR}/man5/; \
	done 
	mkdir -p -m 0755 ${CLIENTVARPKGDIR}
	${INSTALL} -o root -g staff -m 0755 -c OS_X/command.K \
	    ${CLIENTVARPKGDIR}
	${INSTALL} -o root -g staff -m 0755 -c OS_X/apple-neg.T \
	    ${CLIENTVARPKGDIR}
	chown root:wheel ${MPKGDIR}
	find ${MPKGDIR}/* -exec chown root:wheel {} \;
	package ${CLIENTBINPKGDIR} tmp/OS_X/client-bin.info -d ${MPKGDIR}
	package ${CLIENTMANPKGDIR} tmp/OS_X/client-man.info -d ${MPKGDIR}
	package ${CLIENTVARPKGDIR} tmp/OS_X/client-var.info -d ${MPKGDIR}
	package ${SERVERSTARTUPPKGDIR} tmp/OS_X/server-startup.info -d \
	    ${MPKGDIR}
	package ${SERVERSBINPKGDIR} tmp/OS_X/server-sbin.info -d ${MPKGDIR}
	package ${SERVERMANPKGDIR} tmp/OS_X/server-man.info -d ${MPKGDIR}
	cp tmp/OS_X/radmind.info ${MPKGDIR}/radmind-${VERSION}.info
	cp OS_X/radmind.list ${MPKGDIR}/radmind-${VERSION}.list
	cp OS_X/License.rtf ${MPKGDIR}
	cp OS_X/ReadMe.rtf ${MPKGDIR}
	cp OS_X/Welcome.rtf ${MPKGDIR}
	rm -rf ${CLIENTBINPKGDIR} ${CLIENTMANPKGDIR} ${CLIENTVARPKGDIR} \
	    ${SERVERSTARTUPPKGDIR} ${SERVERSBINPKGDIR} ${SERVERMANPKGDIR} tmp
	mv ${MPKGDIR} ../radmind-${VERSION}.mpkg
	cd ..; tar zvcf radmind-${VERSION}.mpkg.tgz radmind-${VERSION}.mpkg/*

clean :
	rm -f *.o a.out core
	rm -f ${TARGETS}
	rm -rf man tmp
