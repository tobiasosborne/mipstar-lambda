#!/usr/bin/env python3
"""Frame renderers for the six clips embedded in compress-explained.html.

Every number drawn here is copied from a repo artefact:
  * suite59q.log / mut59.log   (scratch tutorial-data)
  * claims/CLAIMS.md, docs/DESIGN.md sections 10-12
  * docs/analytic/parts/part1a.tex section 1.2, part1b.tex section 4.3
  * cl_table.b64 -- apply(L, z) for all 8^5 seeds, extracted from the package
    itself and cross-checked against the suite's printed joint-histogram
    supports (512 / 18432 / zero-direction 512, mass 2304 of 32768).

Renders onto figstyle's warm `paper`, so a clip reads as a sheet of the
analytic document lying on the bench.
"""
import base64
import collections
import os
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyBboxPatch, Polygon, Circle
import numpy as np

# ---------------------------------------------------------------- palette
PAPER = "#FBF8F2"
INK = "#22201C"
MUTE = "#6B665E"
RULE = "#D9D3C7"
MACHINE = "#1F6F78"
MACHINELT = "#DCEEF0"
TERM = "#B5561D"
TERMLT = "#F7E4D6"
DESC = "#5B4B8A"
DESCLT = "#E6E1F1"
CHECK = "#3D7A3A"
CHECKLT = "#DFEEDC"
CITED = "#8A857C"
CITEDLT = "#ECE9E2"
FOCUS = "#F2C14E"
FOCUSLT = "#FBEFC9"
BAD = "#B03A2E"

SERIF = ["Latin Modern Roman", "DejaVu Serif"]
SANS = ["Latin Modern Sans", "DejaVu Sans"]
MONO = ["Latin Modern Mono", "DejaVu Sans Mono"]

W, H = 800, 450
DPI = 100
FPS = 25

HERE = os.path.dirname(os.path.abspath(__file__))
SCRATCH = os.environ.get(
    "TUT_SCRATCH",
    "/tmp/claude-1000/-home-tobias-Projects-discussions/"
    "548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tutorial")


def new_fig():
    fig = plt.figure(figsize=(W / DPI, H / DPI), dpi=DPI)
    fig.patch.set_facecolor(PAPER)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, W)
    ax.set_ylim(0, H)
    ax.invert_yaxis()
    ax.set_facecolor(PAPER)
    ax.axis("off")
    return fig, ax


def eyebrow(ax, text, source):
    ax.text(34, 34, text, family=SANS, fontsize=11.5, color=INK,
            weight="bold", va="center")
    ax.text(W - 34, 34, source, family=SANS, fontsize=9, color=MUTE,
            va="center", ha="right")
    ax.plot([34, W - 34], [48, 48], color=RULE, lw=0.8)


def caption(ax, text, color=MUTE, y=H - 26):
    ax.text(34, y, text, family=SANS, fontsize=10, color=color, va="center")


def save(fig, name, i):
    d = os.path.join(SCRATCH, "frames", name)
    os.makedirs(d, exist_ok=True)
    fig.savefig(os.path.join(d, "f%04d.png" % i), dpi=DPI,
                facecolor=PAPER)
    plt.close(fig)


def ease(t):
    return t * t * (3 - 2 * t)


# ================================================================ clip 1
# The two-state equality machine M_= of docs/analytic/parts/part1a.tex 1.2,
# running on (A,B) = (1,1).  Four time rows, Time = 3.
EQ_ROWS = [
    # (i, state, A cells, A head, B cells, B head, W, W head, O, O head, rule)
    (0, "q_0", ["1", "␣", "␣"], 0, ["1", "␣", "␣"], 0,
     ["␣"], 0, ["␣"], 0, "equal-input row"),
    (1, "q_1", ["1", "␣", "␣"], 1, ["1", "␣", "␣"], 1,
     ["1"], 0, ["␣"], 0, "copy row with r = 1"),
    (2, "q_0", ["1", "␣", "␣"], 1, ["1", "␣", "␣"], 1,
     ["1"], 0, ["1"], 0, "halt row with r = 1"),
    (3, "q_h", ["1", "␣", "␣"], 1, ["1", "␣", "␣"], 1,
     ["1"], 0, ["1"], 0, "halted"),
]


def draw_tape(ax, x0, y0, cells, head, label, pulse):
    cw = 34
    ax.text(x0 - 12, y0 + cw / 2, label, family=SANS, fontsize=12,
            color=MACHINE, ha="right", va="center")
    for j, c in enumerate(cells):
        scanned = (j == head)
        fc = FOCUSLT if scanned else "#FFFFFF"
        ec = FOCUS if scanned else RULE
        lw = 1.2 + (1.1 * pulse if scanned else 0)
        ax.add_patch(Rectangle((x0 + j * cw, y0), cw, cw, facecolor=fc,
                               edgecolor=ec, lw=lw))
        ax.text(x0 + j * cw + cw / 2, y0 + cw / 2, c, family=MONO,
                fontsize=15, color=INK if c != "␣" else MUTE,
                ha="center", va="center")
    hx = x0 + head * cw + cw / 2
    ax.add_patch(Polygon([[hx - 6, y0 + cw + 10], [hx + 6, y0 + cw + 10],
                          [hx, y0 + cw + 2]], closed=True,
                         facecolor=MACHINE, edgecolor="none"))


def clip_eq_machine():
    name = "eq-machine"
    hold = 42
    n = len(EQ_ROWS) * hold
    for f in range(n):
        idx = min(f // hold, len(EQ_ROWS) - 1)
        local = (f % hold) / hold
        pulse = max(0.0, 1.0 - local * 4.0)
        i, state, A, ha, B, hb, Wt, hw, O, ho, rule = EQ_ROWS[idx]
        fig, ax = new_fig()
        eyebrow(ax, "The equality machine  M₌  on  (A, B) = (1, 1)",
                "docs/analytic part1a §1.2")
        # state badge
        ax.add_patch(FancyBboxPatch((36, 84), 92, 46,
                                    boxstyle="round,pad=0,rounding_size=6",
                                    facecolor=MACHINELT if state != "q_h" else CHECKLT,
                                    edgecolor=MACHINE if state != "q_h" else CHECK,
                                    lw=1.6))
        ax.text(82, 107, state.replace("_", ""), family=SERIF, fontsize=21,
                color=INK, ha="center", va="center")
        ax.text(82, 146, "state", family=SANS, fontsize=9.5, color=MUTE,
                ha="center", va="center")
        ax.text(150, 100, "step i = %d" % i, family=MONO, fontsize=13,
                color=INK, va="center")
        ax.text(150, 122, "Time = 3 transitions" if idx == 3 else
                "rule: %s" % rule, family=SANS, fontsize=11.5,
                color=CHECK if idx == 3 else MUTE, va="center")
        y = 180
        draw_tape(ax, 300, y, A, ha, "A", pulse)
        draw_tape(ax, 300, y + 60, B, hb, "B", pulse)
        draw_tape(ax, 300, y + 120, Wt, hw, "W", pulse)
        draw_tape(ax, 300, y + 180, O, ho, "O", pulse)
        ax.text(46, y + 6, "input tapes", family=SANS, fontsize=10,
                color=MUTE, va="top")
        ax.text(46, y + 126, "work tape", family=SANS, fontsize=10,
                color=MUTE, va="top")
        ax.text(46, y + 186, "output tape", family=SANS, fontsize=10,
                color=MUTE, va="top")
        caption(ax, "amber = scanned cell   ▴ = head   "
                    "M₌(1,1) = 1,  Time = 3")
        save(fig, name, f)
    return name, n


# ================================================================ clip 2
# YF 3 unfolding, the worked fixed point of part1b 3.3.
BETA_LINES = [
    (r"$Y\,F\;\overline{3}$", None),
    (r"$\rightarrow\;F\,(Y F)\;\overline{3}$", (0, 1)),
    (r"$\rightarrow\;3\cdot(Y F\;\overline{2})$", (0, 1)),
    (r"$\rightarrow\;3\cdot 2\cdot(Y F\;\overline{1})$", (0, 1)),
    (r"$\rightarrow\;3\cdot 2\cdot 1\cdot(Y F\;\overline{0})$", (0, 1)),
    (r"$\rightarrow\;3\cdot 2\cdot 1\cdot 1\;=\;\overline{6}$", None),
]


def clip_beta():
    name = "beta-cascade"
    hold = 30
    n = len(BETA_LINES) * hold + 30
    for f in range(n):
        shown = min(f // hold + 1, len(BETA_LINES))
        local = (f % hold) / hold
        fig, ax = new_fig()
        eyebrow(ax, "Recursion by self-application:  Y F  unfolds only on demand",
                "docs/analytic part1b §3.3")
        ax.text(34, 82, r"$Y=\lambda F.(\lambda x.F(xx))(\lambda x.F(xx))$",
                family=SERIF, fontsize=17, color=TERM, va="center")
        ax.text(34, 112,
                r"$F=\lambda r.\lambda n.\;\mathsf{if}\;(\mathsf{iszero}\;n)"
                r"\;\overline{1}\;(\mathsf{mul}\;n\;(r(\mathsf{pred}\;n)))$",
                family=SERIF, fontsize=13.5, color=MUTE, va="center")
        y = 168
        for k in range(shown):
            txt, hl = BETA_LINES[k]
            alpha = 1.0
            if k == shown - 1:
                alpha = min(1.0, 0.25 + ease(min(local * 3, 1.0)))
            is_live = (k == shown - 1 and hl is not None)
            if is_live:
                ax.add_patch(Rectangle((30, y - 19), 470, 34,
                                       facecolor=FOCUSLT, edgecolor=FOCUS,
                                       lw=1.2, alpha=alpha))
            ax.text(44, y, txt, family=SERIF, fontsize=17,
                    color=INK if k < shown - 1 or hl is None else INK,
                    va="center", alpha=alpha)
            y += 44
        ax.text(560, 190, "one demanded", family=SANS, fontsize=10.5,
                color=MUTE, va="center")
        ax.text(560, 208, "Y F call", family=SANS, fontsize=10.5,
                color=MUTE, va="center")
        ax.text(560, 226, "per numeral level", family=SANS, fontsize=10.5,
                color=MUTE, va="center")
        ax.text(560, 268, "call-by-value needs Z:", family=SANS,
                fontsize=10.5, color=TERM, va="center")
        ax.text(560, 292, r"$Z F =_\beta F(\lambda u.(ZF)u)$", family=SERIF,
                fontsize=13, color=INK, va="center")
        ax.text(560, 322, "the project evaluator is", family=SANS,
                fontsize=10, color=MUTE, va="center")
        ax.text(560, 338, "deterministic CBV, so its", family=SANS,
                fontsize=10, color=MUTE, va="center")
        ax.text(560, 354, "fixed point behaves like Z", family=SANS,
                fontsize=10, color=MUTE, va="center")
        caption(ax, "Y F is finite syntax; recursion is produced by running the "
                    "seed, not by storing an infinite term.")
        save(fig, name, f)
    return name, n


# ================================================================ clip 3
# The CL samplers: 32,768 seeds -> joint (line, point) question histograms.
def load_cl():
    raw = base64.b64decode(open(os.path.join(SCRATCH, "cl_table.b64")).read())
    n = len(raw) // 6
    pt = np.empty(n, dtype=np.int32)
    al = np.empty(n, dtype=np.int32)
    dl = np.empty(n, dtype=np.int32)
    a = np.frombuffer(raw, dtype=np.uint8).reshape(n, 6).astype(np.int32)
    pt[:] = (a[:, 0] << 8) | a[:, 1]
    al[:] = (a[:, 2] << 8) | a[:, 3]
    dl[:] = (a[:, 4] << 8) | a[:, 5]
    return pt, al, dl


def unpack(q):
    return [(q >> 12) & 7, (q >> 9) & 7, (q >> 6) & 7, (q >> 3) & 7, q & 7]


def clip_cl():
    name = "cl-sampler"
    pt, al, dl = load_cl()
    total = len(pt)
    n = 190
    chunk = total // n
    axis_seen, diag_seen = set(), set()
    axis_curve, diag_curve = [], []
    for f in range(n):
        lo, hi = f * chunk, min((f + 1) * chunk, total)
        for i in range(lo, hi):
            axis_seen.add((al[i], pt[i]))
            diag_seen.add((dl[i], pt[i]))
        axis_curve.append(len(axis_seen))
        diag_curve.append(len(diag_seen))
    for f in range(n + 25):
        k = min(f, n - 1)
        seeds = min((k + 1) * chunk, total)
        idx = min(k * chunk + chunk // 2, total - 1)
        fig, ax = new_fig()
        eyebrow(ax, "Conditionally linear samplers over  $\\mathbb{F}_8^5$",
                "TB1 · C4a TESTED")
        # --- left: the F_8^2 point plane
        gx, gy, cell = 44, 92, 27
        for a_ in range(8):
            for b_ in range(8):
                ax.add_patch(Rectangle((gx + a_ * cell, gy + b_ * cell),
                                       cell, cell, facecolor="#FFFFFF",
                                       edgecolor=RULE, lw=0.5))
        qp, qa, qd = unpack(pt[idx]), unpack(al[idx]), unpack(dl[idx])
        # axis line: base point qa[0:2], axis chosen by qa[2] bucket
        ax.text(gx, gy - 12, "$\\mathbb{F}_8^2$  point plane", family=SANS,
                fontsize=10.5, color=MUTE, va="bottom")
        # draw the axis line through the ALine question base
        axis = 0 if qa[2] < 4 else 1
        for t in range(8):
            p = [qa[0], qa[1]]
            p[axis] = t
            ax.add_patch(Rectangle((gx + p[0] * cell, gy + p[1] * cell),
                                   cell, cell, facecolor=MACHINELT,
                                   edgecolor=MACHINE, lw=0.7))
        # diagonal line through the DLine base with its direction
        d0, d1 = qd[3], qd[4]
        if d0 or d1:
            for t in range(8):
                px = (qd[0] ^ _gmul(t, d0)) & 7
                py = (qd[1] ^ _gmul(t, d1)) & 7
                ax.add_patch(Rectangle((gx + px * cell + 4,
                                        gy + py * cell + 4),
                                       cell - 8, cell - 8, facecolor="none",
                                       edgecolor=TERM, lw=1.4))
        ax.add_patch(Rectangle((gx + qp[0] * cell, gy + qp[1] * cell),
                               cell, cell, facecolor=FOCUS,
                               edgecolor=FOCUS, lw=1.4))
        for lbl, col, yy in (("point question", FOCUS, 322),
                             ("axis line", MACHINE, 342),
                             ("diagonal line", TERM, 362)):
            ax.add_patch(Rectangle((gx, yy - 8), 11, 11, facecolor=col,
                                   edgecolor=col if col != FOCUS else INK,
                                   lw=0.6))
            ax.text(gx + 18, yy - 2, lbl, family=SANS, fontsize=10,
                    color=MUTE, va="center")
        ax.text(gx, 396, "seed #%s of 32,768" % format(idx, ","),
                family=MONO, fontsize=10, color=INK, va="center")
        # --- right: support growth
        px0, py0, pw, ph = 330, 104, 430, 250
        ax.add_patch(Rectangle((px0, py0), pw, ph, facecolor="#FFFFFF",
                               edgecolor=RULE, lw=0.8))
        ymax = 20000
        for gv in (0, 5000, 10000, 15000, 20000):
            yy = py0 + ph - ph * gv / ymax
            ax.plot([px0, px0 + pw], [yy, yy], color=RULE, lw=0.6,
                    ls=(0, (2, 3)))
            ax.text(px0 - 8, yy, format(gv, ","), family=MONO, fontsize=9,
                    color=MUTE, ha="right", va="center")
        xs = np.linspace(px0, px0 + pw, n)
        kk = k + 1
        ax.plot(xs[:kk], [py0 + ph - ph * v / ymax for v in diag_curve[:kk]],
                color=TERM, lw=2.0, solid_capstyle="round")
        ax.plot(xs[:kk], [py0 + ph - ph * v / ymax for v in axis_curve[:kk]],
                color=MACHINE, lw=2.0, solid_capstyle="round")
        ax.text(px0 + 12, py0 + 22, "L_DLine × L_Point", family=SANS,
                fontsize=10.5, color=TERM, va="center", ha="left")
        ax.text(px0 + 12, py0 + ph - 18, "L_ALine × L_Point", family=SANS,
                fontsize=10.5, color=MACHINE, va="center", ha="left")
        ax.text(px0, py0 - 12, "distinct (line, point) question pairs seen",
                family=SANS, fontsize=10.5, color=MUTE, va="bottom")
        ax.text(px0, 382, "seeds drawn   %s / 32,768" % format(seeds, ","),
                family=MONO, fontsize=11, color=INK, va="center")
        ax.text(px0, 404, "axis support   %s        diagonal support   %s"
                % (format(axis_curve[k], ","), format(diag_curve[k], ",")),
                family=MONO, fontsize=11,
                color=CHECK if f >= n else INK, va="center")
        caption(ax, "exhaustive over all 8⁵ seeds; the suite prints support "
                    "512 (mass 64) and 18,432 (mass 1 or 8)", y=H - 14)
        save(fig, name, f)
    return name, n + 25


_GF8 = None


def _gmul(a, b):
    global _GF8
    if _GF8 is None:
        # GF(8) with the package's modulus 0x00b = x^3 + x + 1.
        t = [[0] * 8 for _ in range(8)]
        for x in range(8):
            for y in range(8):
                p, xx, yy = 0, x, y
                for _ in range(3):
                    if yy & 1:
                        p ^= xx
                    hi = xx & 4
                    xx = (xx << 1) & 7
                    if hi:
                        xx ^= 0b011
                    yy >>= 1
                t[x][y] = p
        _GF8 = t
    return _GF8[a & 7][b & 7]


# ================================================================ clip 4
# The low-degree test's degree separator, TB1:
#   point = (3, 5), claimed_d = 1, actual_degree = 2,
#   format rule ld_axis_degree, point rule ld_axis_point.
def clip_ldt():
    name = "ldt-line"
    # an illustrative degree-1 bivariate over the package's GF(8)
    def g(x, y):
        return _gmul(3, x) ^ _gmul(5, y) ^ 2

    px, py = 3, 5
    line = [(t, py) for t in range(8)]           # axis line, axis 1, y = 5
    honest = [g(t, py) for t in range(8)]
    cheat = list(honest)
    cheat[6] = honest[6] ^ 4                     # bends it to degree 2
    n = 210
    for f in range(n):
        phase = 0 if f < 70 else (1 if f < 140 else 2)
        local = (f % 70) / 70.0
        fig, ax = new_fig()
        eyebrow(ax, "The classical low-degree test",
                "TB1 · gt-07-ldt.tex")
        gx, gy, cell = 40, 92, 30
        for a_ in range(8):
            for b_ in range(8):
                ax.add_patch(Rectangle((gx + a_ * cell, gy + b_ * cell),
                                       cell, cell, facecolor="#FFFFFF",
                                       edgecolor=RULE, lw=0.5))
        reveal = int(8 * min(1.0, local * 1.6)) if phase == 0 else 8
        for t in range(reveal):
            ax.add_patch(Rectangle((gx + t * cell, gy + py * cell), cell,
                                   cell, facecolor=MACHINELT,
                                   edgecolor=MACHINE, lw=0.8))
            ax.text(gx + t * cell + cell / 2, gy + py * cell + cell / 2,
                    str(honest[t]), family=MONO, fontsize=12, color=MACHINE,
                    ha="center", va="center")
        ax.add_patch(Rectangle((gx + px * cell, gy + py * cell), cell, cell,
                               facecolor=FOCUS, edgecolor=INK, lw=1.2))
        ax.text(gx + px * cell + cell / 2, gy + py * cell + cell / 2,
                str(g(px, py)), family=MONO, fontsize=12, color=INK,
                ha="center", va="center")
        ax.text(gx, gy - 12, "axis line through the point (3, 5) in "
                             "$\\mathbb{F}_8^2$", family=SANS, fontsize=10.5,
                color=MUTE, va="bottom")
        ax.text(gx, gy + 8 * cell + 22, "amber = point · teal = line",
                family=SANS, fontsize=9.5, color=MUTE, va="center")
        # right panel
        rx = 330
        ax.text(rx, 104, "line answer:  claimed degree d = 1",
                family=SANS, fontsize=12, color=INK, va="center")
        vals = honest if phase < 1 else cheat
        for t in range(8):
            bad = (phase >= 1 and vals[t] != honest[t])
            ax.add_patch(Rectangle((rx + t * 34, 122), 34, 34,
                                   facecolor=TERMLT if bad else "#FFFFFF",
                                   edgecolor=BAD if bad else RULE,
                                   lw=1.4 if bad else 0.8))
            ax.text(rx + t * 34 + 17, 139, str(vals[t]), family=MONO,
                    fontsize=13, color=BAD if bad else INK, ha="center",
                    va="center")
        ax.text(rx, 172, "t =  0    1    2    3    4    5    6    7",
                family=MONO, fontsize=9.5, color=MUTE, va="center")
        if phase == 0:
            ax.add_patch(Rectangle((rx, 206), 400, 62, facecolor=CHECKLT,
                                   edgecolor=CHECK, lw=1.2))
            ax.text(rx + 14, 228, "honest restriction", family=SANS,
                    fontsize=12, color=CHECK, va="center")
            ax.text(rx + 14, 250, "degree 1 ≤ d = 1  →  PASS ld_axis_point",
                    family=MONO, fontsize=10, color=INK, va="center")
        else:
            ax.add_patch(Rectangle((rx, 206), 400, 62, facecolor="#F6E3E0",
                                   edgecolor=BAD, lw=1.2,
                                   ls="solid" if phase == 2 else (0, (4, 3))))
            ax.text(rx + 14, 228, "one entry bent", family=SANS, fontsize=12,
                    color=BAD, va="center")
            ax.text(rx + 14, 250, "degree 2 > d = 1  →  REJECT ld_axis_degree",
                    family=MONO, fontsize=10, color=INK, va="center")
        ax.text(rx, 300, "TB1 separator, verbatim from the suite:",
                family=SANS, fontsize=10.5, color=MUTE, va="center")
        ax.text(rx, 324, "point=(GF(2^3)(3), GF(2^3)(5))", family=MONO,
                fontsize=10, color=INK, va="center")
        ax.text(rx, 344, "claimed_d=1  actual_degree=2", family=MONO,
                fontsize=10, color=INK, va="center")
        ax.text(rx, 364, "format_rule=ld_axis_degree", family=MONO,
                fontsize=10, color=BAD, va="center")
        ax.text(rx, 384, "point_rule=ld_axis_point", family=MONO,
                fontsize=10, color=CHECK, va="center")
        caption(ax, "the polynomial is illustrative; the separator point, the "
                    "degrees and both rule names are TB1's printout", y=H - 14)
        save(fig, name, f)
    return name, n


# ================================================================ clip 5
# The zero-on-the-cube certificate, TB0 / C1 / C2.
def clip_cube():
    name = "zero-cube"
    n = 200
    side = 256
    order = np.random.default_rng(7).permutation(side * side)
    for f in range(n):
        fig, ax = new_fig()
        eyebrow(ax, "The zero-on-the-cube certificate:  "
                    "$c_0=\\sum_i c_i\\,\\mathsf{zero}(z_i)+r$",
                "TB0 · C1, C2 TESTED · verdicts/tb0-r4.md")
        phase = 0 if f < 130 else 1
        gx, gy, gs = 40, 96, 256
        ax.add_patch(Rectangle((gx, gy), gs, gs, facecolor="#FFFFFF",
                               edgecolor=RULE, lw=0.8))
        if phase == 0:
            frac = min(1.0, (f / 118.0))
            k = int(frac * side * side)
            img = np.zeros((side, side), dtype=np.uint8)
            img.ravel()[order[:k]] = 1
            ax.imshow(img, extent=(gx, gx + gs, gy + gs, gy),
                      cmap=matplotlib.colors.ListedColormap(
                          ["#FFFFFF", CHECK]), vmin=0, vmax=1,
                      interpolation="nearest", zorder=2)
            done = min(65536, int(frac * 65536))
            ax.text(gx, gy + gs + 24,
                    "witness (i)   %s / 65,536 vanish" % format(done, ","),
                    family=MONO, fontsize=11,
                    color=CHECK if done == 65536 else INK, va="center")
        else:
            img = np.zeros((side, side), dtype=np.uint8)
            ax.imshow(img, extent=(gx, gx + gs, gy + gs, gy),
                      cmap=matplotlib.colors.ListedColormap([CITEDLT]),
                      vmin=0, vmax=1, interpolation="nearest", zorder=2)
            ax.text(gx + gs / 2, gy + gs / 2,
                    "$\\varphi_C$ = false", family=SERIF, fontsize=22,
                    color=BAD, ha="center", va="center", zorder=3)
            ax.text(gx, gy + gs + 24,
                    "witness (iii)   the all-zero witness",
                    family=MONO, fontsize=11, color=BAD, va="center")
        ax.text(gx, gy - 12, "$\\{0,1\\}^{16}$, one pixel per Boolean point",
                family=SANS, fontsize=10.5, color=MUTE, va="bottom")
        rx = 330
        rows = ([("variables in the Tseitin formula", "16"),
                 ("monomials of  $c_0$", "33,432"),
                 ("quotients  $c_1,\\dots,c_{16}$", "16"),
                 ("remainder  $r$", "0"),
                 ("coefficient identity", "true")]
                if phase == 0 else
                [("variables in the Tseitin formula", "16"),
                 ("monomials of  $c_0$", "18,620"),
                 ("quotients  $c_1,\\dots,c_{16}$", "16"),
                 ("remainder  $r$", "2 monomials"),
                 ("coefficient identity", "false")])
        y = 116
        for lbl, val in rows:
            ax.text(rx, y, lbl, family=SANS, fontsize=11.5, color=MUTE,
                    va="center")
            good = val in ("0", "true")
            bad = val in ("2 monomials", "false")
            ax.text(W - 40, y, val, family=MONO, fontsize=13,
                    color=CHECK if good else (BAD if bad else INK),
                    ha="right", va="center")
            ax.plot([rx, W - 40], [y + 17, y + 17], color=RULE, lw=0.6)
            y += 40
        ax.add_patch(Rectangle((rx, 330), 430, 62,
                               facecolor=CHECKLT if phase == 0 else "#F6E3E0",
                               edgecolor=CHECK if phase == 0 else BAD, lw=1.2))
        ax.text(rx + 14, 352,
                "$r=0$: the identity is a formal coefficient equality"
                if phase == 0 else
                "$r\\neq 0$: the rewrite refuses to certify",
                family=SERIF, fontsize=13, color=INK, va="center")
        ax.text(rx + 14, 376,
                "cube vanishing $\\Leftrightarrow$ $\\varphi_C$ on all three "
                "retained witnesses", family=SANS, fontsize=9.5, color=MUTE,
                va="center")
        caption(ax, "TESTED, not proved: the general correspondence stays "
                    "CITED", y=H - 12)
        save(fig, name, f)
    return name, n


# ================================================================ clip 6
# The compression ladder, DESIGN 12.2 / 12.5, C15 CONJECTURE.
LADDER = [
    ("input  V", 9, 9, "quoted 9-level verifier,  $s_0=9$"),
    ("Introspect", 5, 206, "$s_1 = 6 + 200$"),
    ("AnswerReduce + detype", 7, 840, "$s_2 = 206 + 38\\cdot 11 + 216$"),
    ("Anchor", 9, 848, "$s_2 + 8$"),
    ("Repeat  (k = 2)", 9, 1696, "$k\\,(s_2+8)$"),
]


def clip_ladder():
    name = "compress-ladder"
    hold = 34
    n = len(LADDER) * hold + 46
    for f in range(n):
        shown = min(f // hold + 1, len(LADDER))
        local = (f % hold) / hold
        fig, ax = new_fig()
        eyebrow(ax, "Compress = Repeat ∘ AnswerReduce ∘ Introspect",
                "DESIGN §12 · C15")
        base = 384
        step = 60
        for k in range(shown):
            label, lvl, dim, law = LADDER[k]
            y = base - k * step
            grow = ease(min(1.0, local * 2.2)) if k == shown - 1 else 1.0
            wmax = 300
            bw = wmax * (np.log10(dim) / np.log10(1696)) * grow
            live = (k == shown - 1)
            ax.add_patch(Rectangle((40, y - 20), 250, 40,
                                   facecolor=FOCUSLT if live else "#FFFFFF",
                                   edgecolor=FOCUS if live else RULE,
                                   lw=1.4 if live else 0.8))
            ax.text(54, y, label, family=SANS, fontsize=12.5, color=INK,
                    va="center")
            ax.add_patch(Rectangle((310, y - 12), bw, 24, facecolor=DESCLT,
                                   edgecolor=DESC, lw=1.0))
            ax.text(310 + bw + 10, y, "dim %s" % format(dim, ","),
                    family=MONO, fontsize=11.5, color=DESC, va="center",
                    alpha=grow)
            ax.add_patch(Rectangle((700, y - 14), 58, 28,
                                   facecolor=MACHINELT, edgecolor=MACHINE,
                                   lw=1.0))
            ax.text(729, y, "level %d" % lvl, family=SANS, fontsize=11,
                    color=MACHINE, ha="center", va="center")
            if k > 0:
                ax.annotate("", xy=(165, y + 20), xytext=(165, y + step - 20),
                            arrowprops=dict(arrowstyle="-|>", color=INK,
                                            lw=1.4, shrinkA=0, shrinkB=0))
            ax.text(312, y - 22, law, family=SERIF, fontsize=9.5,
                    color=MUTE, va="center", alpha=grow)
        ax.text(40, 78, "level chain   9 → 5 → 7 → 9",
                family=MONO, fontsize=13, color=MACHINE, va="center")
        ax.text(40, 100, "dimensions   206 → 840 → 848 → 1,696",
                family=MONO, fontsize=13, color=DESC, va="center")
        ax.add_patch(Rectangle((470, 64), 290, 46, facecolor=CITEDLT,
                               edgecolor=CITED, lw=1.1, ls=(0, (4, 3))))
        ax.text(484, 80, "designed, not yet executable", family=SANS,
                fontsize=11, color=INK, va="center")
        ax.text(484, 99, "C15 · CONJECTURE · design-v2-r2.md",
                family=MONO, fontsize=9.5, color=MUTE, va="center")
        caption(ax, "n = 2, λ = 32,768, s₀ = 9, k_toy = 2 "
                    "— the fixtures of DESIGN §12.5", y=H - 16)
        save(fig, name, f)
    return name, n


CLIPS = {
    "eq-machine": clip_eq_machine,
    "beta-cascade": clip_beta,
    "cl-sampler": clip_cl,
    "ldt-line": clip_ldt,
    "zero-cube": clip_cube,
    "compress-ladder": clip_ladder,
}

if __name__ == "__main__":
    want = sys.argv[1:] or list(CLIPS)
    for w in want:
        nm, cnt = CLIPS[w]()
        print("%s: %d frames" % (nm, cnt))
