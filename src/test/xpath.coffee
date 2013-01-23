util = require 'util'
util.orginspect = util.inspect
util.inspect = require('eyes').inspector(stream:null)
# console.dir = require 'cdir'

{ parse } = require '../lib/xpath'


module.exports =

    foo: (æ) ->
        exp = parse "/f:iq/o:query/namespace::o:foobar"
        console.log exp # CRAP
        æ.done()

    bar: (æ) ->
        exp = parse '//form[@action = "submi t.html"]//table'#//*[not(text())]'
        console.log exp # CRAP
        æ.done()

    baz: (æ) ->
        exp = parse "/iq/query../namespace::foobar"
        console.log exp # CRAP
        æ.done()

    ns: (æ) ->
        exp = parse "/self::node()/gs:enquiry/@ping:pong"
        console.log exp # CRAP
        æ.done()

    iq: (æ) ->
        exp = parse '/iq[@id="rofl"]/lol:w00t'
        console.log exp # CRAP
        æ.done()

    exp: (æ) ->
        exp = parse '/book/(chapter)[fn:last()]'
        console.log exp # CRAP
        æ.done()

    or: (æ) ->
        exp = parse '/book/(chapter | appendix | section)[fn:last()]'
        console.log exp # CRAP
        æ.done()

    id: (æ) ->
        exp = parse 'id("rofl")/lol:w00t'
        console.log exp # CRAP
        æ.done()

    xmpp: (æ) ->
        exp = parse "/iq[@get] or /iq[@set] and /iq[@error]"
        console.log exp # CRAP
        æ.done()

    blubb: (æ) ->
        exp = parse "id('foo')/child::para[position(5)]"
        console.log exp # CRAP
        æ.done()

    presence: (æ) ->
        exp = parse "self::presence[@type='chat' and @id='id']"
        console.log exp # CRAP
        æ.done()

    info: (æ) ->
        exp = parse "self::iq[@type=result and @id='id']/info:query"
        console.log exp # CRAP
        æ.done()

    or2: (æ) ->
        exp = parse "self::iq[@type=result and @id='id']/roster:query/descendant-or-self::(self::query|self::item)"
        console.log exp # CRAP
        æ.done()

    or3: (æ) ->
        exp = parse "self::presence[@type=unavailable or @type=subscribed or @type=unsubscribed or @type=subscribe or @type=unsubscribe or not(@type)]"
        console.log exp # CRAP
        æ.done()
