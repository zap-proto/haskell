#!/usr/bin/env sh
#
# Regenerate generated modules.
set -e

# Some helpers for reporting info to the caller:
log() {
	printf '%s\n' "$@" >&2
}

err() {
	log $@
	exit 1
}

repo_root="$(realpath $(dirname $0)/..)"
cd "$repo_root"

# Make sure the compiler plugin is up to date.
log "Rebuilding schema compiler plugin..."
cabal new-build zapc-haskell

# We run the code generator from inside gen/lib/, so that it outputs
# modules to the right locations:
cd "$repo_root/zap/gen/lib/"

# Find the compiler plugin executable. It would be nice to just
# use new-run here, but doing so from a subdirectory is a bit fiddly
# and I(zenhack) haven't found a nice way to do it.
exe="$(find $repo_root/dist-newstyle -type f -name zapc-haskell)"

# Make sure we only found one file:
argslen() {
	echo $#
}
case $(argslen $exe) in
	0) err "Error: zapc-haskell executable not found in dist-newstyle." ;;
	1) : ;; # Just one file; we're okay.
	*) err "Error: more than one zapc-haskell executable found in dist-newstyle." ;;
esac

core_inc=$repo_root/core-schema/

# Ok -- do the codegen. Add the compiler plugin to our path and invoke
# zap compile.
log "Generating schema modules for main library..."
export PATH="$(dirname $exe):$PATH"
zap compile \
		-I $core_inc \
		--src-prefix=$core_inc/ \
		-ohaskell \
		$core_inc/zap/*.zap \
		$core_inc/zap/compat/*.zap

log "Generating schema modules for test suite..."
cd "$repo_root/zap-tests/gen/tests"
zap compile \
		-I $core_inc \
		--src-prefix=../../tests/data/ \
		-ohaskell \
		../../tests/data/aircraft.zap \
		../../tests/data/generics.zap

log "Generating schema modules for examples..."
cd "$repo_root/zap-examples/gen/lib"
zap compile \
		-I $core_inc \
		--src-prefix=../../ \
		-ohaskell \
		../../*.zap

# vim: set ts=2 sw=2 noet :
