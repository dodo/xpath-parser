{ parse } = require '../lib/xpath'


module.exports =

    foo: (æ) ->
        exp = parse "/iq/query/namespace::foobar"
        console.log exp

        æ.done()

