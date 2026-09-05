#!/usr/bin/env bash
# Time the COLD package-image build of MIPStarLambda. The image build executes
# src/precompile.jl's TB0 workload (DESIGN.md section 5), which is why the
# warm TB0 test body is far cheaper than a first run. The image is written into
# a fresh scratch depot stacked in front of the default depots, so the shared
# ~/.julia/compiled cache (and any concurrently running copy) is never touched.
#
#   tools/cold_precompile.sh            # prints the cold build seconds
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
depot="$(mktemp -d)"
trap 'rm -rf "$depot"' EXIT
JULIA_DEPOT_PATH="$depot:" julia --startup-file=no --project="$root" -e '
    using Pkg
    seconds = @elapsed Pkg.precompile("MIPStarLambda"; io=devnull)
    println("MIPStarLambda cold image build seconds = ", round(seconds; digits=1),
            " (src/precompile.jl TB0 workload included; scratch depot)")'
