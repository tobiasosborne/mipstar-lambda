#!/usr/bin/env python3
"""Build the GitHub Pages site: wrap the artifact-format explainer
(docs/tutorial/compress-explained.html, which has no doctype/html/head/body
by design) into a standalone HTML document at docs/index.html.
The head replicates the artifact host's minimal reset so the page renders
identically. Source of truth stays docs/tutorial/compress-explained.html."""
import re, pathlib
src = pathlib.Path('docs/tutorial/compress-explained.html').read_text()
m = re.match(r'\s*<title>(.*?)</title>\s*', src, re.S)
title = m.group(1); body = src[m.end():]
head = f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="An interactive tour of the MIP*=RE compression step as built in Julia: sixteen chapters with live instruments on real objects, a three.js machine room, six clips, and the claims ratchet as it stands.">
<meta property="og:title" content="{title}">
<meta property="og:description" content="The compression step of MIP*=RE, rebuilt as executable, adversarially verified transformations — explained with live instruments.">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E%F0%9F%97%9C%EF%B8%8F%3C/text%3E%3C/svg%3E">
<style>
  :root{{color-scheme:light dark}}
  html,body{{margin:0}}
  body{{font:14px system-ui,sans-serif;background:#f7f6f3}}
  img{{max-width:100%}}
  [hidden]{{display:none!important}}
</style>
</head>
<body>
'''
out = head + body.rstrip() + '\n</body>\n</html>\n'
pathlib.Path('docs/index.html').write_text(out)
pathlib.Path('docs/.nojekyll').write_text('')
print('docs/index.html', len(out), 'bytes')
