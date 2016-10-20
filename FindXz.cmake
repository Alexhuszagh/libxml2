#  :copyright: (c) 2015-2016 The Regents of the University of California.
#  :license: MIT, see licenses/mit.md for more details.

# FindXz
# --------
#
# Find Xz include dirs and libraries
#
# Use this module by invoking find_package with the form::
#
#   find_package(Xz
#     [version] [EXACT]      # Minimum or EXACT version e.g. 1.0.6
#     [REQUIRED]             # Fail with error if Xz is not found
#     )
#
# You may also set `Xz_USE_STATIC_LIBS` to prefer static libraries
# to shared ones.
#
# If found, `Xz_FOUND` will be set to true, and `Xz_LIBRARIES`
# and `Xz_INCLUDE_DIRS` will both be set.

include(CheckCXXSourceCompiles)
include(FindPackage)

# REPEAT
# ------

ReturnFound(Xz)

# SUFFIXES
# --------

SetSuffixes(Xz)

# FIND
# ----

FIND_PATH(Xz_INCLUDE_DIRS lzma.h)
FIND_LIBRARY(Xz_LIBRARIES
    NAMES lzma liblzma
    DOC "Xz library path"
)

CheckFound(Xz)
FindStaticLibs(Xz)

# VERSION
# -------

MatchVersion(Xz version/xz "${Xz_INCLUDE_DIRS}/lzma/version.h")

# COMPILATION
# -----------

set(Xz_CODE
"
#include <lzma.h>

int main(int argc, char *argv[])
{
    const char *version;
    version = lzma_version_string();

    return 0;
}
"
)

if(Xz_FOUND)
    CheckCompiles(Xz)
endif()

# REQUIRED
# --------

RequiredPackageFound(Xz)
