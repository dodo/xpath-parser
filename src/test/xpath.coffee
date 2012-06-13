{ parse } = require '../lib/xpath'


module.exports =

    foo: (æ) ->
        exp = parse "/f:iq/o:query/namespace::o:foobar"
        console.log exp

        æ.done()

    bar: (æ) ->
        exp = parse '//form[@action = "submit.html"]//table//*[not(text())]'
        console.log exp

        æ.done()


    baz: (æ) ->
        exp = parse "./iq/query../namespace::foobar"
        console.log exp

        æ.done()

    ns: (æ) ->
        exp = parse "//gs:enquiry"
        console.log exp

        æ.done()
