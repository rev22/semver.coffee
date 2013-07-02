semver.coffee
=============

Coffeescript Library for Semantic Versioning 2.0.0

This is an initial, incomplete release of the source code.

Usage
-----

````coffeescript

{Version} = require "semver"

Version.compare "1.0.0", "1.0.1"

Version.increment "1.2.3" # -> "1.2.4"
Version.incrementMinor "1.2.3" # -> "1.3.0"
Version.incrementMayor "1.2.3" # -> "2.0.0"

````
