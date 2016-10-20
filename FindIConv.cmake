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

# VERSION
# -------

MatchVersion(IConv version/iconv "${IConv_INCLUDE_DIRS}/iconv.h")

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
