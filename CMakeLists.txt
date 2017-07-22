#  :copyright: (c) 2015-2016 The Regents of the University of California.
#  :license: MIT, see licenses/mit.md for more details.

set(CMAKE_LEGACY_CYGWIN_WIN32 1)
cmake_minimum_required(VERSION 2.8)
project(LIBXML C)
set(C_STANDARD 90)

# VERSION
# -------

set(LIBXML_VERSION_MAJOR 2)
set(LIBXML_VERSION_MINOR 9)
set(LIBXML_VERSION_PATCH 4)

# ARGUMENTS
# ---------

option(BUILD_STATIC "Build static libxml2" ON)
option(BUILD_TESTS "Build libxml2 tests" ON)
option(BUILD_ZLIB "Build local zlib" ON)

# OPTIONS
option(ENABLE_C14N "Enable C14N support" OFF)
option(ENABLE_CATALOG "Enable catalog support" OFF)
option(ENABLE_DEBUG "Enable debugging support" OFF)
option(ENABLE_DOCB "Enable DOCB support" OFF)
option(ENABLE_FTP "Enable FTP support" ON)
option(ENABLE_HTML "Enable HTML support" ON)
option(ENABLE_HTTP "Enable HTTP support" ON)
option(ENABLE_ICONV "Enable iconv support" OFF)
option(ENABLE_ICU "Enable icu support" OFF)
option(ENABLE_ISO8859X "Enable iso8859x support if no iconv" ON)
option(ENABLE_LEGACY "Enable deprecated APIs for compatibility" ON)
option(ENABLE_MEM_DEBUG "Enable memory debugging support" OFF)
option(ENABLE_MODULES "Enable dynamic module support" OFF)
option(ENABLE_OUTPUT "Enable serialization support" ON)
option(ENABLE_PATTERN "Enable xmlPattern selection interface" ON)
option(ENABLE_PUSH "Enable PUSH parser interface" ON)
#option(ENABLE_PYTHON "Enable Python libraries" OFF)
option(ENABLE_READER "Enable xmlReader interface" ON)
option(ENABLE_READLINE "Enable readline support" OFF)
option(ENABLE_REGEXPS "Enable regular expression support" ON)
option(ENABLE_RUN_DEBUG "Enable run debugging support" OFF)
option(ENABLE_SAX1 "Enable (older) SAX1 interface" ON)
option(ENABLE_SCHEMAS "Enable Relax-NG and Schemas support" ON)
option(ENABLE_SCHEMATRON "Enable Schematron support" ON)
option(ENABLE_THREADS "Enable threading support" ON)
option(ENABLE_THREAD_ALLOC "Enable per thread memory support" OFF)
option(ENABLE_TREE "Enable DOM like tree manipulation" OFF)
option(ENABLE_VALID "Enable DTD validation support" ON)
option(ENABLE_XINCLUDE "Enable XInclude support" ON)
option(ENABLE_XPATH "Enable XPATH support" ON)
option(ENABLE_XPTR "Enable XPointer support" ON)
option(ENABLE_WRITER "Enable xmlWriter interface" ON)

# COMPRESSION
option(ENABLE_ZLIB "Enable zlib support" ON)
option(ENABLE_LZMA "Enable lzma support" ON)

if(ENABLE_SCHEMAS)
    set(ENABLE_PATTERN ON)
    set(ENABLE_REGEXPS ON)
endif()

if(ENABLE_SCHEMATRON)
    set(ENABLE_SCHEMAS ON)
    set(ENABLE_TREE ON)
    set(ENABLE_XPATH ON)
endif()

if(ENABLE_READER)
    set(ENABLE_PUSH ON)
endif()

if(ENABLE_XPTR)
    set(ENABLE_XPATH ON)
endif()

set(ENABLE_LZMA OFF)
set(ENABLE_ZLIB OFF)
set(ENABLE_HTTP OFF)
set(ENABLE_FTP OFF)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror")
elif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror")
elif(MSVC)
    add_definitions("/WX -wd4013 -wd4018 -wd4047 -wd4244 -wd4996")
endif()

if(BUILD_STATIC)
    if(MINGW OR MSYS)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static")
    elseif(UNIX)
        set(CMAKE_POSITION_INDEPENDENT_CODE ON)
        add_definitions(-fPIC -DPIC)
    elseif(MSVC)
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd /O0 /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
        set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT /Ox /Zi /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
        set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} /MT /Zi /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
        set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} /MT /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
    endif()
endif()

# DEPENDENCIES
# ------------

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_MODULE_PATH})

if(ENABLE_ZLIB)
    find_package(ZLib
        REQUIRED
        "1.0"
    )
endif()

if(ENABLE_LZMA)
    find_package(Xz
        REQUIRED
        "5.0"
    )
endif()

if(ENABLE_ICONV)
    include(IConvLibc)
    IconvLibc()
    if (ICONV_LIBC)
        # IConv automatically linked through libc
        set(IConv_FOUND 1)
    elseif(APPLE)
        # IConv provided as a platform API
        set(IConv_FOUND 1)
        set(IConv_LIBRARIES "/usr/lib/libiconv.dylib")
    else()
        find_package(IConv "1.0" REQUIRED)
    endif()

    include(IConvConst)
endif()

# HEADERS
# -------

include(CheckIncludeFile)

# Check if header can be found. If it can, set uppercase variable
# of version and define includes for the header.
#
# Args:
#   header          Path to header
#
# Example:
#   CheckIncludeFile(sys/stat.h)
#
macro(DefineIncludeHeader header)
    string(REGEX REPLACE "[.\\/]" "_" headerName ${header})
    string(TOUPPER ${headerName} headerName)
    CHECK_INCLUDE_FILE(${header} ${headerName})
    if(${headerName})
        add_definitions(-DHAVE_${headerName}=1)
    endif()
endmacro(DefineIncludeHeader)

# Call DefineIncludeHeader for each argument.
#
# Example:
#   DefineIncludeHeaders(string.h stdio.h sys/stat.h)
#
macro(DefineIncludeHeaders)
    set(headers ${ARGN})
    foreach(header ${headers})
        DefineIncludeHeader(${header})
    endforeach(header)
endmacro(DefineIncludeHeaders)

DefineIncludeHeaders(
    string.h
    stdio.h
    sys/stat.h
    fcntl.h
    unistd.h
    ctype.h
    dirent.h
    errno.h
    malloc.h
    stdarg.h
    sys/stat.h
    sys/types.h
    stdint.h
    inttypes.h
    time.h
    ansidecl.h
    ieeefp.h
    nan.h
    math.h
    limits.h
    fp_class.h
    float.h
    stdlib.h
    sys/socket.h
    netinet/in.h
    arpa/inet.h
    netdb.h
    sys/time.h
    sys/select.h
    poll.h
    sys/mman.h
    sys/timeb.h
    signal.h
    arpa/nameser.h
    resolv.h
    dl.h
    dlfcn.h
)

set(ENABLE_TRIO NOT ${STRING_H} OR NOT ${STDIO_H})

# TODO: need to check for zlib.h and if I have it, define HAVE_ZLIB_H

# FUNCTIONS
# ---------

include(CheckFunctionExists)

# Check if function exists, and add definition if it does.
# Sets uppercase variable if the function is found, and defines
# a preprocessor variable that the variable is found. For example,
# checking `strdup` sets `STRDUP` to `1` and adds `-DHAVE_STRDUP=1` to
# the command-line.
#
# Args:
#   function        Function name
#
# Example:
#   CheckIncludeFile(clock_gettime)
#
macro(DefineFunctionExists function)
    string(TOUPPER ${function} functionName)
    CHECK_FUNCTION_EXISTS(${function} ${functionName})
    if(${functionName})
        add_definitions(-DHAVE_${functionName}=1)
    endif()
endmacro(DefineFunctionExists)


# Call DefineFunctionExists for each argument.
#
# Example:
#   DefineFunctionsExist(strdup strndup strerror)
#
macro(DefineFunctionsExist)
    set(functions ${ARGN})
    foreach(function ${functions})
        DefineFunctionExists(${function})
    endforeach(function)
endmacro(DefineFunctionsExist)


DefineFunctionsExist(
    strdup
    strndup
    strerror
    finite
    isnand
    fp_class
    class
    fpclass
    strftime
    localtime
    gettimeofday
    ftime
    stat
    _stat
    signal
    rand
    rand_r
    srand
    time
    isascii
    mmap
    munmap
    putenv
)

if(NOT MUNMAP)
    # mmap is useless without munmap
    set(MMAP 0)
endif()

# VACOPY
# ------

include(CheckCSourceCompiles)

check_c_source_compiles("
#include <stdarg.h>

int main(int argc, char *argv[])
{
    va_list ap1,ap2;
    va_copy(ap1,ap2);
    return 0;
}
" HAVE_VA_COPY)

if(HAVE_VA_COPY)
    add_definitions(-DHAVE_VA_COPY)
else()
    check_c_source_compiles("
    #include <stdarg.h>

    int main(int argc, char *argv[])
    {
        va_list ap1,ap2;
        __va_copy(ap1,ap2);
        return 0;
    }
    " HAVE___VA_COPY)

    if(HAVE___VA_COPY)
        add_definitions(-DHAVE___VA_COPY)
    endif()
endif()

# VALIST
# ------

check_c_source_compiles("
#include <stdarg.h>

void a(va_list * ap)
{}

int main(int argc, char *argv[])
{
    va_list ap1,ap2;
    a(&ap1);
    ap2 = (va_list) ap1;
    return 0;
}
" VALIST_IS_ARRAY)

if(VALIST_IS_ARRAY)
    add_definitions(-DVALIST_IS_ARRAY)
endif()

# ICONV
# -----

if(ENABLE_ICONV)
    include(IConvConst)
endif()

if(ICONV_CONST)
    add_definitions(-DICONV_CONST=const)
else()
    add_definitions(-DICONV_CONST=)
endif()

# SOURCES
# -------

set(SAX1_SOURCES
    DOCBparser.c
)

set(TRIO_SOURCES
    triostr.c
    trio.c
)

set(LIBXML2_SOURCES
    SAX.c
    entities.c
    encoding.c
    error.c
    parserInternals.c
    parser.c
    tree.c
    hash.c
    list.c
    xmlIO.c
    xmlmemory.c
    uri.c
    valid.c
    xlink.c
    HTMLparser.c
    HTMLtree.c
    debugXML.c
    xpath.c
    xpointer.c
    xinclude.c
    nanohttp.c
    nanoftp.c
    catalog.c
    globals.c
    threads.c
    c14n.c
    xmlstring.c
    buf.c
    xmlregexp.c
    xmlschemas.c
    xmlschemastypes.c
    xmlunicode.c
    xmlreader.c
    relaxng.c
    dict.c
    SAX2.c
    xmlwriter.c
    legacy.c
    chvalid.c
    pattern.c
    xmlsave.c
    xmlmodule.c
    schematron.c
    xzlib.c
    xzlib.c
)

#  $(THREAD_LIBS) $(Z_LIBS) $(LZMA_LIBS) $(ICONV_LIBS) $(M_LIBS) $(WIN32_EXTRA_LIBADD)

if(ENABLE_TRIO)
    list(APPEND LIBXML2_SOURCES ${TRIO_SOURCES})
endif()

if(ENABLE_SAX1)
    list(APPEND LIBXML2_SOURCES ${SAX1_SOURCES})
endif()

# THREADS
# -------

include(FindThreads)

if(ENABLE_THREADS)
    if(CMAKE_USE_PTHREADS_INIT)
        list(APPEND LIBXML_LINK_LIBRARIES pthread)
    elseif(CMAKE_USE_WIN32_THREADS_INIT)
        add_definitions(-DHAVE_WIN32_THREADS -DHAVE_COMPILER_TLS)
    else()
        message(WARNING "Threads requested but no suitable thread implementation found")
        set(ENABLE_THREADS OFF)
    endif()

    #add_definitions(-D_REENTRANT)
endif()

# MACROS
# ------

# Replace symbol with 0 or 1 boolean expression.
#
# Args:
#   stringName              Name of string variable
#   substitute              Substitute string
#   boolean                 Boolean value to replace with 0/1
#
macro(ReplaceBool stringName substitute boolean)
    if(${boolean})
        set(replace 1)
    else()
        set(replace 0)
    endif()
    string(REPLACE ${substitute} ${replace} ${stringName} "${${stringName}}")

endmacro(ReplaceBool)

# VERSION
# -------

set(INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include/libxml")
file(READ "${INCLUDE_DIR}/xmlversion.h.in" VERSION_BUFFER)
string(REPLACE "@VERSION@" "${LIBXML_VERSION_MAJOR}.${LIBXML_VERSION_MINOR}.${LIBXML_VERSION_PATCH}" VERSION_BUFFER "${VERSION_BUFFER}")
string(REPLACE "@LIBXML_VERSION_NUMBER@" "${LIBXML_VERSION_MAJOR}0${LIBXML_VERSION_MINOR}0${LIBXML_VERSION_PATCH}" VERSION_BUFFER "${VERSION_BUFFER}")
string(REPLACE "@LIBXML_VERSION_EXTRA@" "" VERSION_BUFFER "${VERSION_BUFFER}")

ReplaceBool(VERSION_BUFFER "@WITH_TRIO@" ${ENABLE_TRIO})
ReplaceBool(VERSION_BUFFER "@WITH_TREE@" ${ENABLE_TREE})
ReplaceBool(VERSION_BUFFER "@WITH_THREADS@" ${ENABLE_THREADS})
ReplaceBool(VERSION_BUFFER "@WITH_THREAD_ALLOC@" ${ENABLE_THREAD_ALLOC})
ReplaceBool(VERSION_BUFFER "@WITH_OUTPUT@" ${ENABLE_OUTPUT})
ReplaceBool(VERSION_BUFFER "@WITH_PUSH@" ${ENABLE_PUSH})
ReplaceBool(VERSION_BUFFER "@WITH_READER@" ${ENABLE_READER})
ReplaceBool(VERSION_BUFFER "@WITH_PATTERN@" ${ENABLE_PATTERN})
ReplaceBool(VERSION_BUFFER "@WITH_WRITER@" ${ENABLE_WRITER})
ReplaceBool(VERSION_BUFFER "@WITH_SAX1@" ${ENABLE_SAX1})
ReplaceBool(VERSION_BUFFER "@WITH_FTP@" ${ENABLE_FTP})
ReplaceBool(VERSION_BUFFER "@WITH_HTTP@" ${ENABLE_HTTP})
ReplaceBool(VERSION_BUFFER "@WITH_VALID@" ${ENABLE_VALID})
ReplaceBool(VERSION_BUFFER "@WITH_HTML@" ${ENABLE_HTML})
ReplaceBool(VERSION_BUFFER "@WITH_LEGACY@" ${ENABLE_LEGACY})
ReplaceBool(VERSION_BUFFER "@WITH_C14N@" ${ENABLE_C14N})
ReplaceBool(VERSION_BUFFER "@WITH_CATALOG@" ${ENABLE_CATALOG})
ReplaceBool(VERSION_BUFFER "@WITH_DOCB@" ${ENABLE_DOCB})
ReplaceBool(VERSION_BUFFER "@WITH_XPATH@" ${ENABLE_XPATH})
ReplaceBool(VERSION_BUFFER "@WITH_XPTR@" ${ENABLE_XPTR})
ReplaceBool(VERSION_BUFFER "@WITH_XINCLUDE@" ${ENABLE_XINCLUDE})
ReplaceBool(VERSION_BUFFER "@WITH_ICONV@" ${ENABLE_ICONV})
ReplaceBool(VERSION_BUFFER "@WITH_ICU@" ${ENABLE_ICU})
ReplaceBool(VERSION_BUFFER "@WITH_ISO8859X@" ${ENABLE_ISO8859X})
ReplaceBool(VERSION_BUFFER "@WITH_DEBUG@" ${ENABLE_DEBUG})
ReplaceBool(VERSION_BUFFER "@WITH_MEM_DEBUG@" ${ENABLE_MEM_DEBUG})
ReplaceBool(VERSION_BUFFER "@WITH_RUN_DEBUG@" ${ENABLE_RUN_DEBUG})
ReplaceBool(VERSION_BUFFER "@WITH_REGEXPS@" ${ENABLE_REGEXPS})
ReplaceBool(VERSION_BUFFER "@WITH_SCHEMAS@" ${ENABLE_SCHEMAS})
ReplaceBool(VERSION_BUFFER "@WITH_SCHEMATRON@" ${ENABLE_SCHEMATRON})
ReplaceBool(VERSION_BUFFER "@WITH_MODULES@" ${ENABLE_MODULES})
ReplaceBool(VERSION_BUFFER "@WITH_ZLIB@" ${ENABLE_ZLIB})
ReplaceBool(VERSION_BUFFER "@WITH_LZMA@" ${ENABLE_LZMA})

file(WRITE "${INCLUDE_DIR}/xmlversion.h" "${VERSION_BUFFER}")

# FLAGS
# -----

if(CMAKE_COMPILER_IS_GNUCC)
    set(CMAKE_C_FLAGS "-Wno-incompatible-pointer-types -Wno-format-extra-args -Wno-builtin-macro-redefined ${CMAKE_C_FLAGS}")
elseif(CMAKE_C_COMPILER_ID MATCHES "Clang")
    set(CMAKE_C_FLAGS "-Wno-incompatible-pointer-types -Wno-macro-redefined -Wno-empty-body ${CMAKE_C_FLAGS}")
elseif(MSVC)
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd /O0 /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT /Ox /Zi /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
    set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} /MT /Zi /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} /MT /Fd${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb")
endif()

add_definitions(-DSEND_ARG2_CAST= -DGETHOSTBYNAME_ARG_CAST=)

if(MSVC AND (ENABLE_HTTP OR ENABLE_FTP))
    add_definitions(-D_WINSOCKAPI_)
endif()

if(WIN32)
    add_definitions(-DWIN32 -D_WINDOWS -D_MBCS -DNOLIBTOOL -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
endif()

if(CMAKE_BUILD_TYPE MATCHES Release)
    add_definitions(-DNDEBUG)
else()
    add_definitions(-D_DEBUG)
endif()

if(MINGW)
    add_definitions(-DHAVE_W32API_H)
endif()

# INCLUDES
# --------

include_directories(include)

if(ENABLE_LZMA)
    include_directories(${Xz_INCLUDE_DIRS})
endif()

if(ENABLE_ZLIB)
    include_directories(${ZLib_INCLUDE_DIRS})
endif()

if(ENABLE_ICONV)
    include_directories(${IConv_INCLUDE_DIRS})
endif()

# LIBRARIES
# ---------

if(BUILD_STATIC)
    add_library(libxml2
        STATIC
        ${LIBXML2_SOURCES}
    )
    add_definitions(-DLIBXML_STATIC)
else()
    add_library(libxml2
        SHARED
        ${LIBXML2_SOURCES}
    )
endif()

target_link_libraries(libxml2
    ${Xz_LIBRARIES}
    ${ZLib_LIBRARIES}
    ${IConv_LIBRARIES}
)
set_target_properties(libxml2
    PROPERTIES OUTPUT_NAME xml2
)
