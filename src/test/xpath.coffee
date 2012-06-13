{ parse } = require '../lib/xpath'


module.exports =

    foo: (æ) ->
        exp = parse "/iq/query/namespace::foobar"
        console.log exp

        æ.done()

    bar: (æ) ->
        exp = parse '//form[@action = "submit.html"]//table//*[not(text())]'
        console.log exp

        æ.done()


