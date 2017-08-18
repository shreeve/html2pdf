#!/usr/bin/env coffee

# =============================================================================
# html2pdf-pup.coffee: Convert html files in one directory to pdf files in another.
#
# Author: Steve Shreeve <steve.shreeve@gmail.com>
#  Legal: MIT License => https://opensource.org/licenses/MIT
# =============================================================================

###

# Install npm dependencies:

  npm install -g coffeescript@next
  npm install fs-extra
  npm install puppeteer

# Install dependencies for Google Chrome Headless

  sudo apt-get install  \
    libpangocairo-1.0-0 \
    libx11-xcb-dev      \
    libxcomposite-dev   \
    libxcursor-dev      \
    libxdamage-dev      \
    libxi-dev           \
    libxtst-dev         \
    libnss3             \
    libcups2-dev        \
    libXss-dev          \
    libxrandr-dev       \
    libgconf-2-4        \
    libasound2-dev      \
    libatk1.0-0         \
    libgtk-3-dev        \
  ;

###

fs     = require 'fs-extra'
path   = require 'path'
pup    = require 'puppeteer'

# command-line
[script, source, target] = process.argv.slice 1
script = script.match(/\/([^\/]+)$/)[1]
source and target            or throw "#{script} <source_dir> <target_dir>"
source = path.resolve source
target = path.resolve target
fs.existsSync(source) or throw "missing #{source}"
fs.existsSync(target) or fs.mkdirp(target) and console.log("making #{target}")

margin =
  top:    '0.4in'
  right:  '0.4in'
  bottom: '0.4in'
  left:   '0.4in'

convert = (page) ->
  list = await fs.readdir source

  for file, i in list
    src = path.join source, file; continue unless $ = src.match /\/([^\/.]+?)\.html$/
    dst = path.join target, "#{$[1]}.pdf"
    url = "file://#{src}"

    await page.goto url, waitUntil: 'load'
    await page.pdf { path: dst, margin }
    console.log dst

do ->
  try
    http = await pup.launch()
    page = await http.newPage()
    await convert page
  catch err
    console.log "Exception: #{err}"
    process.exit 1
  finally
    http?.close()

  console.log 'Done'
