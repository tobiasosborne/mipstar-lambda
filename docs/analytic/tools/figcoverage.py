#!/usr/bin/env python3
"""Figure coverage per page, from the .aux written by pdflatex.

usage: python3 tools/figcoverage.py [analytic-underpinnings.aux] [--from A --to B]
Prints one line per page: page number, number of figures placed on it, and the
section(s) starting on it.  Then lists the pages in the range with NO figure.
Exit status 1 if any page in the range lacks a figure (so a lane can gate on it).
"""
import re, sys, collections

args = sys.argv[1:]
aux = "analytic-underpinnings.aux"
lo, hi = 1, 10**6
i = 0
while i < len(args):
    a = args[i]
    if a == "--from": lo = int(args[i+1]); i += 2
    elif a == "--to": hi = int(args[i+1]); i += 2
    else: aux = a; i += 1

text = open(aux, encoding="utf-8", errors="replace").read()
figs = collections.Counter()
for m in re.finditer(r"\\@writefile\{lof\}\{\\contentsline \{figure\}.*?\}\{(\d+)\}\{[^}]*\}%?", text):
    figs[int(m.group(1))] += 1
secs = collections.defaultdict(list)
for m in re.finditer(r"\\@writefile\{toc\}\{\\contentsline \{(part|section|subsection)\}\{\\numberline \{([^}]*)\}(.*?)\}\{(\d+)\}\{", text):
    kind, num, title, page = m.groups()
    title = re.sub(r"\\[a-zA-Z]+\s*", "", title).replace("{", "").replace("}", "")
    secs[int(page)].append(f"{kind[:4]} {num} {title[:40]}")
lastpage = 0
for m in re.finditer(r"\\@writefile\{(?:toc|lof)\}\{\\contentsline .*?\}\{(\d+)\}\{", text):
    lastpage = max(lastpage, int(m.group(1)))
m = re.search(r"\\gdef \\@abspage@last\{(\d+)\}", text)
if m: lastpage = max(lastpage, int(m.group(1)))
hi = min(hi, lastpage)
missing = []
print(f"{'page':>4} {'figs':>4}  sections starting here")
for p in range(lo, hi + 1):
    n = figs.get(p, 0)
    flag = "" if n else "   <-- no figure"
    print(f"{p:>4} {n:>4}  {'; '.join(secs.get(p, []))}{flag}")
    if n == 0: missing.append(p)
print(f"\nfigures in range: {sum(figs[p] for p in range(lo, hi+1))}; pages without a figure: {missing}")
sys.exit(1 if missing else 0)
