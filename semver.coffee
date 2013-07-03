# semver.coffee - Library for Semantic Versioning

# Version: 1.0.0-beta
  
# Copyright (c) 2013 Michele Bini

# This program is free software: you can redistribute it and/or modify
# it under the terms of the version 3 of the GNU General Public License
# as published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Semantic Versioning v2.0.0 library (per semver.org)

# Tiny object system

object =
  extend: (fields) ->
    o = (fields) -> arguments.callee.extend fields
    o[n] = v for n,v of this
    o[n] = v for n,v of fields
    o

library = object.extend
  baseExtend: object.extend
  exports: object.extend
  extend: (fields) ->
    o = @baseExtend fields
    o = o.baseExtend (p = o.public)
    exports = o.exports p
    adapt = (m, l) -> () -> m.apply l, arguments
    exports[n] = adapt o[n], o for n of exports
    o.baseExtend { exports }

# Subset of the library that only supports normal versions, without
# build or prerelease parts 

NormalVersion = library
  intcmp: (a,b) -> (d) ->
    a = a|0
    b = b|0
    if a < b
      do d.less
    else if b < a
      do d.more
    else
      do d.same
  asciicmp: (a,b) -> (d) ->
    a = "#{a}"
    b = "#{b}"
    if a < b
      do d.less
    else if b < a
      do d.more
    else
      do d.same

  couldNotParseVersion: (s) -> throw "Could not parse version: " + s

  fromString: (s) ->
    return s if s.major?
    if /^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$/.test(s)
      [major, minor, patch] = (x|0 for x in s.split("."))
      { major, minor, patch }
    else
      @couldNotParseVersion s

  toString: (v) -> "#{v.major}.#{v.minor}.#{v.patch}"
  
  public:
    compare: (a,b) -> (d) =>
      a = @fromString a
      b = @fromString b
      (@intcmp a.major,b.major)
        less: -> do d.less
        more: -> do d.more
        same: =>
          (@intcmp a.minor,b.minor)
            less: -> do d.less
            more: -> do d.more
            same: =>
              (@intcmp a.patch,b.patch)
                less: -> do d.less
                more: -> do d.more
                same: -> do d.same

    increment:       (v) ->
      { major, minor, patch } = @fromString v
      @toString { major, minor, patch: patch + 1 }
    incrementMinor:  (v) ->
      { major, minor } = @fromString v
      @toString { major, minor: minor + 1, patch: 0 }
    incrementMajor:  (v) ->
      { major } = @fromString v
      @toString { major: major + 1, minor: 0, patch: 0 }

  # Evaluates the mutual compatibility of versions x and y
  # less: y's api extends x's api in a backward-compatible fashion
  # same: x and y have the same api and are mutually compatible
  # more: x's api extends y's api in a backward-compatible fashion
  # incompatible: x and y are mutually incompatible
  # This function assumes that both major versions are > 0
  compatibility: (x,y) ->
    a = @fromString a; b = @fromString b
    (@intcmp a.major,b.major)
      less: -> do d.incompatible
      more: -> do d.incompatible
      same: =>
        (@intcmp a.minor,b.minor)
          less: -> do d.less
          more: -> do d.more
          same: -> do d.same

# Extend library to complete support of Semantic Versioning v2.0.0
Version = NormalVersion
  NormalVersion: NormalVersion
  couldNotParseBuildVersion: (s) -> throw "Could not parse build version: " + s
  couldNotParsePreVersion: (s) -> throw "Could not parse pre-release version: " + s
  fromString: (s) ->
    return s if s.major?
    full   = s
    build  = null
    pre    = null
    if /^[^+]*[+][^+]*$/.test(s)
      [s, build] = s.split "+"
      build = build.split "."
      unless build.length > 0
        @couldNotParseBuildVersion full
    rx = /-.*/
    if pre = s.match rx
      pre = pre[0].substring(1).split(".")
      s = s.replace rx, ""
      unless pre.length > 0
        @couldNotParsePreVersion full
    v = @NormalVersion.fromString(s)
    v.build  = build  if build
    v.pre    = pre    if pre
    v

  toString: (v) ->
    s = NormalVersion.toString v
    s += "-" + v.pre.join    "." if v.pre
    s += "+" + v.build.join  "." if v.build
    s

  comparePreId: (a,b) -> (d) =>
    n = /^[0-9]*$/
    an = n.test(a)
    bn = n.test(b)
    if an
      if bn
        (@intcmp a,b) d
      else
        do d.less
    else
      if bn
        do d.more
      else
        (@asciicmp a,b) d        

  comparePre: (a,b) -> (d) =>
    i = 0
    done = false
    result = null
    while (ai = a[i])? and (bi = b[i])?
      (@comparePreId ai, bi)
        less: -> result = do d.less; done = true
        more: -> result = do d.more; done = true
        same: ->
      return result if done
      i++
    bi = b[i] # This may seem redundant, but it's actually necessary
    if ai?
      if bi?
        (@comparePreId ai, bi) d
      else
        do d.more
    else
      if bi?
        do d.less
      else
        do d.same 

  public:
    compare: (a,b) -> (d) =>
      a = @fromString a
      b = @fromString b
      (@NormalVersion.compare a,b)
        less: -> do d.less
        more: -> do d.more
        same: =>
          a = a.pre
          b = b.pre
          if a
            if b
              (@comparePre a, b) d
            else
              do d.less
          else
            if b
              do d.more
            else
              do d.same
    isNormal:   (v) ->
      v = @fromString v
      !(v.pre or v.build)
    normalize:  (v) ->
      { major, minor, patch } = @fromString v
      @NormalVersion.toString { major, minor, patch }

exports.Version = Version.exports
