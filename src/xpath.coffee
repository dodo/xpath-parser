
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
            stack[0].localname = star
            hit = star
        # whitespace
        else if (space = string.match(/^\s+/))
            hit = space[0] # ignore it
        # self:: shortcut
        else if (axis = string.match(/^\.+/))
            axis = axis[0]
            if stack[0].axis?
                stack.unshift({})
            stack[0].seperator = "/"
            stack[0].expression = "node()"
            stack[0].axis = switch(axis.length)
                when 1 then "self"
                when 2 then "parent"
                else throw error "too many '.'"
            hit = axis
        # seperator
        else if (sep = string.match(/^\/+/))
            hit = '/' # leave the other / to be matched again
            sep = sep[0]
            if stack[0].axis?
                stack.unshift({})
            stack[0].seperator = hit
            stack[0].axis = switch(sep.length)
                when 1 then "child"
                when 2 then "descendant-or-self"
                else throw error "too much /"
            stack[0].expression = "node()" if sep.length is 2
        # axis
        else if (axis = string.match(/^::/))
            axis = axis[0]
            unless stack[0]?.localname?.length
                throw error "need some chars for axis"
            stack[0].axis = stack[0].localname
            stack[0].localname = null
            stack[0].QName = null
            hit = axis
        # prefix
        else if (prefix = string.match(/^:/))
            prefix = prefix[0]
            unless stack[0]?.localname?.length
                throw error "need some chars for prefix"
            stack[0].prefix = stack[0].localname
            stack[0].localname = null
            stack[0].QName = null
            hit = prefix
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
                (stack[0].predicate ?= []).push(parse(predicate, yes))
        # operator
        else if inpredicate and (operator = string.match(/^((|!|<|>)=)|>|</))
            stack[0].operator = hit = operator[0]
        # operator value
        else if inpredicate and stack[0].operator? and
          (value = string.match(/^'([^']*)'|"([^"]*)"|[^\s\/.]+/))
            value = value[0]
            hit = value
            if (val = value.match(/^("|')(.*)("|')$/))
                value = val[2] # unescape
            stack[0].value = value
        # name
        else if (name = string.match(/^\w+/))
            name = name[0]
            stack[0].localname = name
            stack[0].QName = name
            if stack[0].prefix?
                stack[0].QName = stack[0].prefix + ":" + name
            hit = name
        # not parsable
        else throw error "not parsable"
        # remove hit from string
        string = string.substr(hit.length)
    return stack.reverse()
