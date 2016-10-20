#  :copyright: (c) 2015-2016 The Regents of the University of California.
#  :license: MIT, see licenses/mit.md for more details.

# Check if IConv's first parameter takes constant argument.
#
# IConv implementations support two function signatures:
#   iconv(iconv_t cd, char **pIn, size_t *srclen, char **pIn, size_t *dstlen);
#   iconv(iconv_t cd, char **pIn, size_t *srclen, const char **pIn, size_t *dstlen);
#
# Sets `ICONV_CONST` if iconv takes a constant argument.

include(CheckCSourceCompiles)

# CHECK
# -----

if(NOT IConv_FOUND)
    message(SEND_ERROR "Cannot try to compile Iconv without the library")
endif()

list(APPEND CMAKE_REQUIRED_INCLUDES ${IConv_INCLUDE_DIRS})

check_source_compiles("
#include <stdlib.h>
#include <iconv.h>

int main()
{
    iconv_t conv = iconv_open(0, 0);
    const char *pIn;
    char *pOut;
    size_t srclen, dstlen;
    iconv(conv, &pIn, &srclen, &pOut, &dstlen);
    iconv_close(conv);
    return 0;
}
" ICONV_CONST)
