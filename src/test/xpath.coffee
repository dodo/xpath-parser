util = require 'util'
util.orginspect = util.inspect
util.inspect = require('eyes').inspector(stream:null)
# console.dir = require 'cdir'

{ parse } = require '../lib/xpath'


module.exports =

    foo: (æ) ->
        exp = parse "/f:iq/o:query/namespace::o:foobar"
        console.log exp
        æ.deepEqual exp.map((e)-> e.prefix), ['f','o','o']
        æ.deepEqual exp.map((e)-> e.axis), ['child','child','namespace']
        æ.deepEqual exp.map((e)-> e.nc), ['iq','query','foobar']
        æ.done()

    bar: (æ) ->
        exp = parse '//form[@action = "submi t.html"]//table'#//*[not(text())]'
        console.log exp
        æ.deepEqual exp.map((e)-> e.nc), ['node','form','node','table']
        æ.deepEqual exp.map((e)-> e.axis), [
            'descendant-or-self'
            'child'
            'descendant-or-self'
            'child'
        ]
        æ.deepEqual exp[0]?.args, [{}]
        æ.deepEqual exp[2]?.args, [{}]
        æ.deepEqual exp[1]?.predicate, [
            [operator:'=', args:[
                [axis:'attribute', nc:'action', q:'action']
                [value:'submi t.html']
            ]]
        ]
        æ.done()

    baz: (æ) ->
        exp = parse "/iq/query../namespace::foobar"
        console.log exp
        æ.deepEqual exp.map((e)-> e.axis), ['child','child','parent','namespace']
        æ.deepEqual exp.map((e)-> e.nc), ['iq','query','node','foobar']
        æ.deepEqual exp[2]?.args, [{}]
        æ.done()

    'self::ns': (æ) ->
        exp = parse "/self::node()/gs:enquiry/@ping:pong"
        console.log exp
        æ.deepEqual exp.map((e)-> e.prefix), [undefined,'gs','ping']
        æ.deepEqual exp.map((e)-> e.axis), ['self','child','attribute']
        æ.deepEqual exp.map((e)-> e.nc), ['node','enquiry','pong']
        æ.deepEqual exp[0]?.args, [[{}]] # FIXME is this right?
        æ.done()

    './ns': (æ) ->
        exp = parse "./gs:enquiry/attribute::ping:pong"
        console.log exp
        æ.deepEqual exp.map((e)-> e.prefix), [undefined,'gs','ping']
        æ.deepEqual exp.map((e)-> e.axis), ['self','child','attribute']
        æ.deepEqual exp.map((e)-> e.nc), ['node','enquiry','pong']
        æ.deepEqual exp[0]?.args, [{}]
        æ.done()

    iq: (æ) ->
        exp = parse '/iq[@id="rofl"]/lol:w00t'
        console.log exp
        æ.deepEqual exp.map((e)-> e.prefix), [undefined,'lol']
        æ.deepEqual exp.map((e)-> e.axis), ['child','child']
        æ.deepEqual exp.map((e)-> e.nc), ['iq','w00t']
        æ.deepEqual exp[0]?.predicate, [
            [operator:'=', args:[
                [axis:'attribute', nc:'id', q:'id']
                [value:'rofl']
            ]]
        ]
        æ.done()

    exp: (æ) ->
        exp = parse '/überbook/(chapter)[fn:last()]'
        console.log exp
        æ.deepEqual exp.map((e)-> e.axis), ['child','child']
        æ.deepEqual exp.map((e)-> e.nc), ['überbook', undefined]
        æ.deepEqual exp[1]?.predicate, [
            [axis:'self', prefix:'fn', nc:'last', q:'fn:last', args:[[{}]]]
        ]
        æ.deepEqual exp[1]?.expression, [nc:'chapter',q:'chapter',axis:'child']
        æ.done()

    or: (æ) ->
        exp = parse '/book/(chapter | appendix | section)[fn:last()]'
        console.log exp
        æ.deepEqual exp.map((e)-> e.axis), ['child','child']
        æ.deepEqual exp.map((e)-> e.nc), ['book', undefined]
        æ.deepEqual exp[1]?.predicate, [
            [axis:'self', prefix:'fn', nc:'last', q:'fn:last', args:[[{}]]]
        ]
        æ.deepEqual exp[1]?.expression, [
            operator:'union', args:[
                [expression:[
                    operator:'union', args:[
                        [nc:'chapter', q:'chapter', axis:'child']
                        [nc:'appendix', q:'appendix', axis:'child']
                    ]
                ]]
                [nc:'section', q:'section', axis:'child']
            ]
        ]
        æ.done()

    id: (æ) ->
        exp = parse 'id("rofl")/lol:w00t'
        console.log exp
        æ.deepEqual exp.map((e)-> e.prefix), [undefined, 'lol']
        æ.deepEqual exp.map((e)-> e.axis), ['child','child']
        æ.deepEqual exp.map((e)-> e.nc), ['id','w00t']
        æ.deepEqual exp[0]?.args, [[value:'rofl']]
        æ.done()

    short: (æ) ->
        exp = parse "c | o | l"
        console.log exp
        æ.equals 1, exp?.length
        æ.deepEqual exp[0]?.expression, [
            operator:'union', args:[
                [expression:[
                    operator:'union', args:[
                        [nc:'c', q:'c', axis:'child']
                        [nc:'o', q:'o', axis:'child']
                    ]
                ]]
                [nc:'l', q:'l', axis:'child']
            ]
        ]
        æ.done()

    xmpp: (æ) ->
        exp = parse "/iq[@get] or /iq[@set] and /iq[@error]"
        console.log exp
        æ.equals 1, exp?.length
        æ.equals 1, exp[0]?.expression?.length
        æ.deepEqual exp[0]?.expression?[0]?.expression, [
            operator:'or', args:[
                [seperator:'/', axis:'child', nc:'iq', q:'iq', predicate:[
                    [nc:'get', q:'get', axis:'attribute']
                ]]
                [operator:'and', args:[
                    [seperator:'/', axis:'child', nc:'iq', q:'iq', predicate:[
                        [nc:'set', q:'set', axis:'attribute']
                    ]]
                    [seperator:'/', axis:'child', nc:'iq', q:'iq', predicate:[
                        [nc:'error', q:'error', axis:'attribute']
                    ]]
                ]]
            ]
        ]
        æ.done()

    blubb: (æ) ->
        exp = parse "id('foo')/child::para[position(5)]"
        console.log exp
        æ.deepEqual exp.map((e)-> e.axis), ['child','child']
        æ.deepEqual exp.map((e)-> e.nc), ['id','para']
        æ.deepEqual exp[0]?.args, [[value:'foo']]
        æ.deepEqual exp[1]?.predicate, [
            [axis:'self', nc:'position', q:'position', args:[
                [axis:'child', nc:'5', q:'5']
            ]]
        ]
        æ.done()

    presence: (æ) ->
        exp = parse "self::presence[@type='überchat' and @id='id']"
        console.log exp
        æ.equals 1, exp?.length
        æ.equals 1, exp[0]?.predicate?.length
        æ.equals 1, exp[0]?.predicate?[0]?.length
        æ.deepEqual exp[0]?.predicate?[0]?[0]?.expression, [
            operator:'and', args:[
                [expression:[operator:'=', args:[ # FIXME what is the expression doing here?
                    [axis:'attribute', nc:'type', q:'type']
                    [value:'überchat']
                ]]]
                [operator:'=', args:[
                    [axis:'attribute', nc:'id', q:'id']
                    [value:'id']
                ]]
            ]
        ]
        æ.done()

    info: (æ) ->
        exp = parse "self::iq[@type=result and @id='id']/info:query"
        console.log exp
        æ.deepEqual exp.map((e)-> e.prefix), [undefined, 'info']
        æ.deepEqual exp.map((e)-> e.axis), ['self','child']
        æ.deepEqual exp.map((e)-> e.nc), ['iq','query']
        æ.done()

    or2: (æ) ->
        exp = parse "self::iq[@type=result and @id='id']/roster:query/descendant-or-self::(self::query|self::item)"
        console.log exp
        æ.deepEqual exp.map((e)-> e.prefix), [undefined, 'roster', undefined]
        æ.deepEqual exp.map((e)-> e.axis), ['self','child','descendant-or-self']
        æ.deepEqual exp.map((e)-> e.nc), ['iq','query', null] # FIXME not undefined?
        æ.done()

    or3: (æ) ->
        exp = parse "self::presence[@type=unavailable or @type=subscribed or @type=unsubscribed or @type=subscribe or @type=unsubscribe or not(@type)]"
        console.log exp
        æ.deepEqual exp.map((e)-> e.axis), ['self']
        æ.deepEqual exp.map((e)-> e.nc), ['presence']
        æ.done()
