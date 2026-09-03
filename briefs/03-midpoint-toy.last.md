Implemented [code](/home/tobias/Projects/discussions/toys/midpoint/midpoint.jl), [tests](/home/tobias/Projects/discussions/toys/midpoint/test.jl), [mutations](/home/tobias/Projects/discussions/toys/midpoint/mutations/run.jl), and [proof](/home/tobias/Projects/discussions/toys/midpoint/PROOF.md).
Red run exited 1: `SystemError: opening file ".../midpoint.jl": No such file or directory`.
```text
term IR and exact evaluators |    9      9  0.6s
exhaustive exact midpoint values | 1380   1380  3.1s
r(n) for cheating value <= 1/2
n  r(n)  r(n+1)/r(n)
1  1  3.0
2  3  2.0
3  6  1.833333
4  11  2.0
5  22  2.045455
6  45  1.977778
7  89  2.0
8  178  -
naive independent amplification |   84     84  0.4s
M1/M2/M3 killed (exit 1 each)
midpoint mutation suite |    3      3  26.6s
```
Finalization issue `mipstar-lambda-o1n` filed. Failures verbatim: `fatal: Unable to create '.../.git/index.lock': Read-only file system`; `Error 1105: fatal: remote 'origin' not found`; `fatal: No configured push destination.`