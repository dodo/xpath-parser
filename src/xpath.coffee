
pad = (s, n) ->
    new Array(n+1).join(s)

exports.parse = parse = (string = "", inpredicate = no) ->
    error = (msg) ->
        p = orig.length-string.length
        new Error "#{msg}\n#{orig}\n#{pad '-',p}^"
    # lets begin …
    orig = "#{string}"
    stack = [{}]
    while string.length
        hit = null
        # allstars
        if (star = string.match(/^\*+/))
            star = star[0]
            if star.length > 1
                throw error "only on star at once"
            stack[0].name = star
            hit = star
        # whitespace
        else if (space = string.match(/^\s+/))
            hit = space[0] # ignore it
        # self:: shortcut
        else if (axis = string.match(/^\.+/))
            axis = axis[0]
            stack.push(separator:'/', name:'node()')
            stack[0].axis = switch(axis.length)
                when 1 then "self"
                when 2 then "parent"
                else throw error "too many '.'"
            hit = axis
        # seperator
        else if (sep = string.match(/^\/+/))
            hit = '/' # leave the other / to be matched again
            sep = sep[0]
            if stack[0].seperator?
                stack.unshift({})
            stack[0].seperator = hit
            stack[0].axis = switch(sep.length)
                when 1 then "child"
                when 2 then "descendant-or-self"
                else throw error "too much /"
            stack[0].name = "node()" if sep.length is 2
        # axis
        else if (axis = string.match(/^::/))
            axis = axis[0]
            unless stack[0]?.name?.length
                throw error "need some chars for axis"
            stack[0].axis = stack[0].name
            stack[0].name = null
            hit = axis
        # namespace
        else if (ns = string.match(/^:/))
            ns = ns[0]
            unless stack[0]?.name?.length
                throw error "need some chars for namespace"
            stack[0].namespace = stack[0].name
            stack[0].name = null
            hit = ns
        # attribute shortcut
        else if (attr = string.match(/^@+/))
            attr = attr[0]
            if attr.length > 1
                throw error "only on @ at once"
            stack[0].axis = "attribute"
            hit = attr
        # predicate
        else if not inpredicate and (predicate = string.match(/^\[([^\]]*)\]/))
            hit = predicate[0]
            predicate = predicate[1]
            if predicate.length # empty? is ok, i guess
                # TODO parse predicate
                (stack[0].predicate ?= []).push(parse(predicate, yes))
        # operator
        else if inpredicate and (operator = string.match(/((|!|<|>)=)|>|</))
            operator = operator[0]
            stack[0].operator = operator
            hit = operator
        # operator value
        else if inpredicate and stack[0].operator? and (value = string.match(/^[^\s]+/))
            value = value[0]
            hit = value
            if (val = value.match(/^("|')(.*)("|')$/))
                value = val[2] # unescape
            stack[0].value = value
        # name
        else if (name = string.match(/^\w+/))
            name = name[0]
            stack[0].name = name
            hit = name
        # not parsable
        else throw error "not parsable"
        # remove hit from string
        string = string.substr(hit.length)
    return stack.reverse()
