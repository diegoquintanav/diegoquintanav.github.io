#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = 'Diego Quintana'
SITENAME = 'On the shoulders of giants'
SITEURL = ''



PATH = 'content/blog'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (('Pelican', 'http://getpelican.com/'),
         ('Python.org', 'http://python.org/'),
         ('Jinja2', 'http://jinja.pocoo.org/'),
         ('You can modify those links in your config file', '#'),)

# Social widget
SOCIAL = (('You can add links in your config file', '#'),
          ('Another social link', '#'),)

DEFAULT_PAGINATION = 5

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
THEME = 'themes/pelican-alchemy/alchemy'

MARKUP = ('md', 'ipynb')

PLUGIN_PATHS = ['./plugins']
PLUGINS = ['ipynb.markup', 'pelican_plugins.render_math']


# pelican-alchemy settings
# https://github.com/nairobilug/pelican-alchemy/wiki/Settings

DESCRIPTION = "A github blog, by Diego Quintana"
HIDE_AUTHORS = True
ICONS = (
    ('github', 'https://github.com/diegoquintanav'),
    ('linkedin', 'https://www.linkedin.com/in/diego-quintana-valenzuela/'),
    ('envelope', 'mailto:daquintanav@gmail.com')
)

GOOGLE_ANALYTICS = 'UA-108898322-1'