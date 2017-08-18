#!/usr/bin/env coffee

# =============================================================================
# html2pdf-cdp.coffee: Convert html files in one directory to pdf files in another.
#
# Author: Steve Shreeve <steve.shreeve@gmail.com>
#  Legal: MIT License => https://opensource.org/licenses/MIT
# =============================================================================

### Launch Google Chrome Headless (macOS or Linux)

    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
      --headless --remote-debugging-port=9222 --disable-gpu https://chromium.org &

    node_modules/puppeteer/.local-chromium/linux-494755/chrome-linux/chrome-wrapper \
      --headless --remote-debugging-port=9222 --disable-gpu https://chromium.org &

###

# Install npm dependencies:
#
# npm install -g coffeescript@next
# npm install chrome-remote-interface
# npm install fs-extra

fs     = require 'fs-extra'
path   = require 'path'
Chrome = require 'chrome-remote-interface'

# command-line
[script, source, target] = process.argv.slice 1
script = script.match(/\/([^\/]+)$/)[1]
source and target            or throw "#{script} <source_dir> <target_dir>"
source = path.resolve source
target = path.resolve target
fs.existsSync(source) or throw "missing #{source}"
fs.existsSync(target) or fs.mkdirp(target) and console.log("making #{target}")

convert = ({ Page }) ->
  list = await fs.readdir source

  for file, i in list
    src = path.join source, file; continue unless $ = src.match /\/([^\/.]+?)\.html$/
    dst = path.join target, "#{$[1]}.pdf"
    url = "file://#{src}"

    await Page.navigate { url }
    await Page.loadEventFired()
    { data } = await Page.printToPDF()
    await fs.writeFile dst, Buffer.from(data, 'base64')
    console.log dst

Chrome (client) =>
  { Page } = client

  try
    await Page.enable()
    await convert { Page }
    await client.close()
  catch err
    console.log "Exception: #{err}"
    process.exit 1

  console.log 'Done'
