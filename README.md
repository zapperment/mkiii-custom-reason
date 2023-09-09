# mkiii-custom-reason

Custom Reason control surface for the Novation SL MkIII master keyboards.

## Prerequisites

To install the control surface, you need to install [luabundler](https://github.com/Benjamin-Dobell/luabundler) first.
Refer to their documentation on how to do it.

## Installation

Run the installer like so:

```
./install.sh
```

On Windows, use PowerShell:

```
./install.ps1
```

## Development

### Prerequisites

For development, make sure

* you have the latest version of [Node.js](https://nodejs.org/) and [Yarn](https://yarnpkg.com/) installed
* you have a [Lua compiler](https://www.lua.org/home.html), version 5.1.1 in your command line console's path (we use the old Lua version because that's what Reason uses, as well)

### Debugging

You can install the codecs with a "debug" option:

```
yarn install:mac:debug
```

...or...

```
yarn install:win:debug
```

This adds an additional MIDI port to the MIDI controller setup in Reason. Assign a virtual port here. Then you can run the "log" script using Yarn, passing the name of the debug MIDI port as option:

```
yarn log "Bome MIDI Translator 5"
```

**Note:** [Bome](https://www.bome.com/products/miditranslator) is a useful tool when you're using Windows to set up virtual ports. On Mac, it's easier, just use the app "Audio MIDI Setup" that comes with macOS.

When you have the debug port set up and the logger is running, you can add logging statements in the Lua code to print useful information:

```
local debugUtils = require("src.lib.debugUtils)
debugUtils.log("hello world")
```

The log statements are sent from Reason to the debug log script as MIDI system exclusive messages.

### Testing

There are some suites of automated tests. Run them like so:

```
yarn test
```

## Ackknowledgements

* Uses [luaunit](https://github.com/bluebird75/luaunit), BSD License, copyright (c) 2005-2018, Philippe Fremy
* Uses [luabundler](https://github.com/Benjamin-Dobell/luabundler), MIT License, copyright (c) 2020 Benjamin Dobell
