#  :copyright: (c) 2015-2016 The Regents of the University of California.
#  :license: MIT, see licenses/mit.md for more details.

# Check if IConv's first parameter takes constant argument.
#
# IConv implementations support two function signatures:
#   iconv(iconv_t cd, char **pIn, size_t *srclen, char **pOut, size_t *dstlen);
#   iconv(iconv_t cd, const char **pIn, size_t *srclen, char **pOut, size_t *dstlen);
#
# Sets `ICONV_CONST` if iconv takes a constant argument.

include(CheckPrototypeDefinition)

# PROTOTYPE
# ---------

list(APPEND CMAKE_REQUIRED_INCLUDES ${IConv_INCLUDE_DIRS})

check_prototype_definition(iconv
    "size_t iconv(iconv_t cd, const char **pIn, size_t *srclen, char **pOut, size_t *dstlen)"
    "NULL"
    "stdlib.h;iconv.h"
    ICONV_CONST
)

if(ICONV_CONST)
    add_definitions(-DICONV_CONST=const)
else()
    add_definitions(-DICONV_CONST=)
endif()
