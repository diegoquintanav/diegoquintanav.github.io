#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = 'Diego Quintana'
SITENAME = 'On the shoulders of giants'
SITEURL = ''

PATH = 'content'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
# LINKS = (('Pelican', 'http://getpelican.com/'),
#          ('Python.org', 'http://python.org/'),
#          ('Jinja2', 'http://jinja.pocoo.org/'),
#          ('You can modify those links in your config file', '#'),)

# Social widget
# SOCIAL = (('You can add links in your config file', '#'),
#           ('Another social link', '#'),)

DEFAULT_PAGINATION = 5

# publish everything as draft unless explictly specified otherwise
DEFAULT_METADATA = {
    'status': 'draft',
}

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
THEME = 'themes/pelican-alchemy/alchemy'

MARKUP = ('md', 'ipynb')

PLUGIN_PATHS = ['./plugins']
PLUGINS = ['ipynb.markup', 'pelican_plugins.render_math']


# --- pelican-alchemy settings --------------------------------------
# https://github.com/nairobilug/pelican-alchemy/wiki/Settings

SITESUBTITLE = "Diego Quintana's blog"
SITEIMAGE = '/images/profile.png width=400 height=400'
HIDE_AUTHORS = True

ICONS = (
    ('github', 'https://github.com/diegoquintanav'),
    ('linkedin', 'https://www.linkedin.com/in/diego-quintana-valenzuela/'),
    ('stack-overflow', 'https://stackoverflow.com/users/5819113/bluesmonk'),
    ('envelope', 'mailto:daquintanav@gmail.com')
)

STATIC_PATHS = ['extras', 'images']
# PYGMENTS_STYLE = 'monokai'
PYGMENTS_STYLE = 'borland'
RFG_FAVICONS = True

DIRECT_TEMPLATES = ['index', 'tags', 'categories', 'authors', 'archives', 'sitemap']

# --- pelican plugins settings ---------------------

# ipynb
# if you create jupyter files in the content dir, snapshots are saved with the same
# metadata. These need to be ignored.
IGNORE_FILES = [".ipynb_checkpoints"]
IPYNB_GENERATE_SUMMARY = True
IPYNB_FIX_CSS = True
IPYNB_EXPORT_TEMPLATE = './themes/nb_templates/custom.tpl'
