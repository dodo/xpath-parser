
pad = (s, n) ->
    new Array(n+1).join(s)

exports.parse = (string = "") ->
    orig = "#{string}"
    stack = []
    while string.length
        hit = null
        # allstars
        if (star = string.match(/^\*+/))
            star = star[0]
            if star.length > 1
                throw new Error "only on star at once"
            if stack[0].name?.length
                throw new Error "already found a name"
            stack[0].name = star
            hit = star
        # self:: shortcut
        else if (axis = string.match(/^\.+/))
            axis = axis[0]
            if stack[0]?.axis?.length
                throw new Error "already found an axis"
            unless stack.length # make an exception when this is the first hit
                stack.push {}
            stack[0].axis = switch(axis.length)
                when 1 then "self"
                when 2 then "parent"
                else throw new Error "too many '.'"
            hit = axis
        # seperator
        else if (sep = string.match(/^\/+/))
            sep = sep[0]
            if sep.length > 2
                throw new Error "too much /"
            stack.unshift(separator:sep)
            hit = sep
        # axis
        else if (axis = string.match(/^::/))
            axis = axis[0]
            unless stack[0]?.name?.length
                throw new Error "need some chars for axis"
            if stack[0].axis?.length
                throw new Error "already found an axis"
            stack[0].axis = stack[0].name
            stack[0].name = null
            hit = axis
        # attribute shortcut
        else if (attr = string.match(/^@+/))
            attr = attr[0]
            if attr.length > 1
                throw new Error "only on @ at once"
            if stack[0].axis?.length
                throw new Error "already found an axis"
            stack[0].axis = "attribute"
            hit = attr
        # predicate
        else if (predicate = string.match(/^\[([^\]]*)\]/))
            hit = predicate[0]
            predicate = predicate[1]
            if predicate.length # empty? is ok, i guess
                # TODO parse predicate
                (stack[0].predicate ?= []).push(predicate)
        # name
        else if (name = string.match(/^\w+/))
            name = name[0]
            if stack[0].name?.length
                throw new Error "already found a name"
            stack[0].name = name
            hit = name
        # not parsable
        else
            p = orig.length - string.length
            throw new Error "not parsable\n#{orig}\n#{pad '-',p}^"
        string = string.substr(hit.length)
    return stack.reverse()
