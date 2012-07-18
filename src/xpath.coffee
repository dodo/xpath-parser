
pad = (s, n) ->
    new Array(n+1).join(s)

open_scope = (scope, stack, string, bracket) ->
    stack.unshift({})
    scope.unshift({bracket, ptr:stack.length, pos:string.length})

close_scope = (scope, stack, opts = {}) ->
    # remove scoped entries from stack
    exp = stack.splice(0, stack.length - scope[0].ptr + 1)
    # add argument to operator
    if stack[0].operator
        (stack[0].args ?= []).push(exp.reverse())
        if opts.operator
            stack.unshift({})
            return
        exp = [stack[0]]
        stack[0] = {}
    # predicate
    if scope[0].bracket is "["
        (stack[0].predicate ?= []).push(exp.reverse())
    # function call or expression
    else # ")"
        # function call
        if stack[0].q? # we found already some text before
            stack[0].args = exp.reverse()
        # expression
        else
            stack[0].expression = exp.reverse()

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
            stack[0].nc = star
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
            stack[0].q = stack[0].nc = "node"
            stack[0].args = [{}]
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
            if sep.length is 2
                stack[0].q = stack[0].nc = "node"
                stack[0].args = [{}]
        # axis - ::
        else if (axis = string.match(/^::/))
            axis = axis[0]
            unless stack[0]?.nc?.length
                throw error "need some chars for axis"
            stack[0].axis = stack[0].nc
            stack[0].nc = null
            stack[0].q = null
            hit = axis
        # prefix - :
        else if (prefix = string.match(/^:/))
            prefix = prefix[0]
            unless stack[0]?.nc?.length
                throw error "need some chars for prefix"
            stack[0].prefix = stack[0].nc
            stack[0].nc = null
            stack[0].q = null
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
            open_scope(scope, stack, string, bracket)
            hit = bracket
        # close bracket - ] )
        else if (bracket = string.match(/^(\]|\))/))
            bracket = bracket[0]
            opening = if bracket is "]" then "[" else "("
            if not scope[0].bracket is opening
                string = orig.substr(orig.length - scope[0].pos) # restore string
                throw error "other unclosed scope"
            close_scope(scope, stack)
            scope.shift()
            hit = bracket
        # name
        else if (name = string.match(/^\w+/))
            name = name[0]
            stack[0].nc = name
            stack[0].q = name
            stack[0].axis ?= "child"
            if stack[0].prefix?
                stack[0].q = stack[0].prefix + ":" + name
            hit = name
        # comparator - = != <= >= > <
        else if (comparator = string.match(/^((|!|<|>)=)|>|</))
            operator = comparator[0]
            # update scope
            i = stack.length - scope[0].ptr++ + 1
            stack.splice(i, 0, {operator})
            close_scope(scope, stack, operator:yes)
            scope[0].ptr = stack.length
            hit = operator
        # value - "…" '…'
        else if scope[0]? and (value = string.match(/^('([^']*)'|"([^"]*)")/))
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
