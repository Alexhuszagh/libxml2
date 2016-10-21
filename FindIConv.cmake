#  :copyright: (c) 2015-2016 The Regents of the University of California.
#  :license: MIT, see licenses/mit.md for more details.

# FindIConv
# ---------
#
# Find IConv include dirs and libraries
#
# Use this module by invoking find_package with the form::
#
#   find_package(IConv
#     [version] [EXACT]      # Minimum or EXACT version e.g. 1.14.0
#     [REQUIRED]             # Fail with error if IConv is not found
#     )
#
# You may also set `IConv_USE_STATIC_LIBS` to prefer static libraries
# to shared ones.
#
# If found, `IConv_FOUND` will be set to true, and `IConv_LIBRARIES`
# and `IConv_INCLUDE_DIRS` will both be set.


include(CheckCXXSourceCompiles)
include(FindPackage)

# REPEAT
# ------

ReturnFound(IConv)

# SUFFIXES
# --------

SetSuffixes(IConv)

# FIND
# ----

FIND_PATH(IConv_INCLUDE_DIRS iconv.h)
FIND_LIBRARY(IConv_LIBRARIES
    NAMES iconv libiconv libiconv-2
    DOC "IConv library path"
)

CheckFound(IConv)
FindStaticLibs(IConv)

# MACROS
# ------

# Convert Hex character to decimal.
#
# Args:
#   output      Output variable name
#   value       Hex value
#
macro(HexCHarToDecimal output value)
    if(${value} MATCHES "[0-9]")
        set(${output} ${value})
    elseif(${value} MATCHES "[aA]")
        set(${output} 10)
    elseif(${value} MATCHES "[bB]")
        set(${output} 11)
    elseif(${value} MATCHES "[cC]")
        set(${output} 12)
    elseif(${value} MATCHES "[dD]")
        set(${output} 13)
    elseif(${value} MATCHES "[eE]")
        set(${output} 14)
    elseif(${value} MATCHES "[fF]")
        set(${output} 15)
    else()
        MESSAGE(SEND_ERROR "Cannot recognize hex character")
    endif()

endmacro(HexCHarToDecimal)


# Convert Hex number to decimal.
#
# Args:
#   output      Output variable name
#   value       Hex value
#
macro(HexToDecimal output value)
    if(${value} EQUAL 0)
        set(${output} 0)
    else()
        set(index 0)
        string(LENGTH "${value}" length)

        # iterate while can extract
        set(${output} 0)
        while(index LESS  length)

            string(SUBSTRING "${value}" ${index} 1 char)
            HexCHarToDecimal(char ${char})

            math(EXPR POWAH "(1<<((${length}-${index}-1)*4))")
            math(EXPR char "(${char}*${POWAH})")
            math(EXPR ${value} "${${VAR}}+${char}")
            math(EXPR index "${index}+1")
        endwhile()
    endif()

endmacro(HexToDecimal)

# VERSION
# -------

if(IConv_FOUND)
    file(STRINGS "${IConv_INCLUDE_DIRS}/iconv.h" Iconv_VERSION_CONTENTS REGEX "#define _LIBICONV_VERSION 0[xX][0-9a-fA-F]+")

    string(REGEX REPLACE ".*#define _LIBICONV_VERSION (0[xX][0-9a-fA-F]+).*" "\\1" IConv_VERSION_HEX "${Iconv_VERSION_CONTENTS}")
    HexToDecimal(IConv_VERSION_NUMBER ${IConv_VERSION_HEX})
    math(EXPR IConv_VERSION_MAJOR "${IConv_VERSION_NUMBER} >> 8")
    math(EXPR IConv_VERSION_MAJOR "${IConv_VERSION_NUMBER} - (${IConv_VERSION_MAJOR} << 8)")
    set(IConv_VERSION_PATCH 0)

    MatchVersion(IConv)
endif()

# COMPILATION
# -----------

set(IConv_CODE
"
#include <iconv.h>

int main(int argc, char *argv[])
{
    iconv_t conv = iconv_open(0, 0);
    iconv_close(conv);
    return 0;
}
"
)
if(IConv_FOUND)
    CheckCompiles(IConv)
endif()

# REQUIRED
# --------

RequiredPackageFound(IConv)
