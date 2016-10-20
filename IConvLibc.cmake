#  :copyright: (c) 2015-2016 The Regents of the University of California.
#  :license: MIT, see licenses/mit.md for more details.

# Check if IConv is automatically linked via Libc. This is
# normally true if using GLibc.
#
# Sets `ICONV_LIBC` if true.

# FILE
# ----

set(ICONV_SOURCE "
#include <stdlib.h>
#include <iconv.h>

int main()
{
    iconv_t conv = iconv_open(0, 0);
    iconv_close(conv);
    return 0;
}
")

macro(IconvLibc)
    set(SRCDIR "${CMAKE_CURRENT_BINARY_DIR}")
    set(ICONV_FILE "${SRCDIR}/iconv_test.c")
    file(WRITE "${ICONV_FILE}" "${ICONV_SOURCE}")
    try_compile(ICONV_LIBC "${SRCDIR}" "${ICONV_FILE}")
endmacro(IconvLibc)
