
pad = (s, n) ->
    new Array(n+1).join(s)

exports.parse = parse = (string = "") ->
    error = (msg) ->
        p = orig.length-string.length
        new Error "#{msg}\n#{orig}\n#{pad '-',p}^"
    # lets begin …
    orig = "#{string}"
    stack = [{}]
    scope = [] # for brackets
    while string.length
        hit = null
        # allstars - *
        if (star = string.match(/^\*+/))
            star = star[0]
            if star.length > 1
                throw error "only on star at once"
            stack[0].localname = star
            hit = star
        # whitespace
        else if (space = string.match(/^\s+/))
            hit = space[0] # ignore it
        # self:: shortcut - . ..
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
        # seperator - / //
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
        # axis - ::
        else if (axis = string.match(/^::/))
            axis = axis[0]
            unless stack[0]?.localname?.length
                throw error "need some chars for axis"
            stack[0].axis = stack[0].localname
            stack[0].localname = null
            stack[0].QName = null
            hit = axis
        # prefix - :
        else if (prefix = string.match(/^:/))
            prefix = prefix[0]
            unless stack[0]?.localname?.length
                throw error "need some chars for prefix"
            stack[0].prefix = stack[0].localname
            stack[0].localname = null
            stack[0].QName = null
            hit = prefix
        # attribute shortcut - @
        else if (attr = string.match(/^@+/))
            attr = attr[0]
            if attr.length > 1
                throw error "only on @ at once"
            stack[0].axis = "attribute"
            hit = attr
        # open bracket - [ (
        else if (bracket = string.match(/^(\[|\()/))
            bracket = bracket[0]
            stack.unshift({})
            scope.unshift({bracket, ptr:stack.length, pos:string.length})
            hit = bracket
        # close bracket - ] )
        else if (bracket = string.match(/^(\]|\))/))
            bracket = bracket[0]
            opening = if bracket is "]" then "[" else "("
            if not scope.some((s) -> s.bracket is opening)
                throw error "no opening bracket"
            if not scope[0].bracket is opening
                string = orig.substr(orig.length - scope[0].pos) # restore string
                throw error "other unclosed scope"
            # remove scoped entries from stack
            exp = stack.splice(0, stack.length - scope[0].ptr + 1)
            # predicate
            if bracket is "]"
                (stack[0].predicate ?= []).push(exp.reverse())
            # function call or expression
            else # ")"
                # function call
                if stack[0].QName? # we found already some text before
                    stack[0].args = exp.reverse()
                # expression
                else
                    stack[0].expression = exp.reverse()
            scope.shift()
            hit = bracket
        # operator - = != <= >= > <
        else if (operator = string.match(/^((|!|<|>)=)|>|</))
            stack[0].operator = hit = operator[0]
        # name
        else if (name = string.match(/^\w+/))
            name = name[0]
            stack[0].localname = name
            stack[0].QName = name
            stack[0].axis ?= "child"
            if stack[0].prefix?
                stack[0].QName = stack[0].prefix + ":" + name
            hit = name
        # value - "…" '…'
        else if (stack[0].operator? or scope[0]?.bracket is "(") and
          (value = string.match(/^('([^']*)'|"([^"]*)"|[^\s\/.]+)/))
            value = value[0]
            hit = value
            if (val = value.match(/^("|')(.*)("|')$/))
                value = val[2] # unescape
            stack[0].value = value
        # not parsable
        else throw error "not parsable"
        # remove hit from string
        string = string.substr(hit.length)
    # all open brackets should be closed by now, if not, throw an error
    if scope.length
        err = scope[scope.length - 1] # get first found bracket
        string = orig.substr(orig.length - err.pos) # restore string
        throw error "no closing bracket"
    return stack.reverse()
