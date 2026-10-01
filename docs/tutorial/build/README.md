# docs/tutorial/build/ is FROZEN history

- `build.py` and `part-*.html` were last in sync with the page at commit 3060d29; later commits (af72ba8, c50400d, and the text sync of brief 87) edited `docs/tutorial/compress-explained.html` in place.
- Do NOT run `build.py`: it would regress the page (old counts 84/84, 43 baselines, "3 lanes", C14 CONJECTURE).
- The shipped `docs/tutorial/compress-explained.html` is the source of truth. Edit it directly, then from the repo root run `python3 tools/build_site.py` to regenerate `docs/index.html`.
- The embedded data blobs (`data/`, `video/`) and their Julia generators (`extract.jl`, `guards.jl`, `probe.jl`) remain here as provenance only.
- Decision recorded by the orchestrator, 2026-10-01 (brief 87).
