semver.coffee
=============

[Coffeescript](http://coffeescript.org) Library for [Semantic Versioning](http://semver.org)

This is an initial, incomplete release of the source code.

Created according to [Semantic Versioning v2.0.0](http://semver.org/spec/v2.0.0.html)

Usage
-----

````coffeescript

{Version} = require "semver"

# Input two version strings
x = "1.0.0"
y = "1.0.1"

# Now compare them
(Version.compare x, y)
  less: -> console.log "#{x} < #{y}"
  same: -> console.log "#{x} = #{y}"
  more: -> console.log "#{x} > #{y}"

Version.increment       "1.2.3"  # -> "1.2.4"
Version.incrementMinor  "1.2.3"  # -> "1.3.0"
Version.incrementMajor  "1.2.3"  # -> "2.0.0"

````

License and authors
-------------------

Copyright (c) 2013 Michele Bini

This program is free software: you can redistribute it and/or modify
it under the terms of the version 3 of the GNU General Public License
as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
