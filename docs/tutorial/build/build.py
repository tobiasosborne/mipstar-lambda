#!/usr/bin/env python3
"""Assemble docs/tutorial/compress-explained.html.

Concatenates the authored parts, then inlines:
  * six WebM clips and their JPEG posters as data URIs (video/ )
  * the exhaustive sampler question table (data/cl_table.b64)
  * the 54x54 answer-reduction guard map (data/tb2-guard-map.txt)

No network, no <!DOCTYPE>/<html>/<head>/<body> tags: the file starts with
<title>Compress, Explained</title>.
"""
import base64
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(HERE), "compress-explained.html")
PARTS = ["part-a-head.html", "part-b1.html", "part-b2.html",
         "part-b3.html", "part-b4.html", "part-c.html"]
CLIPS = ["eq-machine", "beta-cascade", "cl-sampler",
         "ldt-line", "zero-cube", "compress-ladder"]


def datauri(path, mime):
    with open(path, "rb") as fh:
        return "data:%s;base64,%s" % (mime, base64.b64encode(fh.read()).decode("ascii"))


def main():
    doc = "".join(open(os.path.join(HERE, p), encoding="utf-8").read() for p in PARTS)

    for clip in CLIPS:
        v = os.path.join(HERE, "video", clip + ".webm")
        p = os.path.join(HERE, "video", clip + ".jpg")
        doc = doc.replace("__VIDEO_%s__" % clip, datauri(v, "video/webm"))
        doc = doc.replace("__POSTER_%s__" % clip, datauri(p, "image/jpeg"))

    tbl = open(os.path.join(HERE, "data", "cl_table.b64"), encoding="ascii").read().strip()
    doc = doc.replace("__CL_TABLE__", tbl)

    g = {}
    for line in open(os.path.join(HERE, "data", "tb2-guard-map.txt"), encoding="utf-8"):
        k = line.split("=", 1)[0]
        if k in ("TYPES", "SETS", "IDX"):
            g[k] = line.rstrip("\n").split("=", 1)[1]
    doc = doc.replace("__GUARD_TYPES__", g["TYPES"])
    doc = doc.replace("__GUARD_SETS__", g["SETS"])
    doc = doc.replace("__GUARD_IDX__", g["IDX"])

    leftovers = [t for t in ("__VIDEO_", "__POSTER_", "__CL_TABLE__", "__GUARD_") if t in doc]
    if leftovers:
        sys.exit("unsubstituted placeholder(s): %s" % leftovers)

    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(doc)
    size = os.path.getsize(OUT)
    print("wrote %s  %.2f MB (%d bytes)" % (OUT, size / 1048576.0, size))


if __name__ == "__main__":
    main()
