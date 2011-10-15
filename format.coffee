_format_pattern = /%(?:\(([^)]+)\))?s/g
this.str_format = (string, args...) ->
    # "formats" a string in the "old" python fashion
    #
    # Use:
    # ----
    # str_format('test string'); // "test string"
    # str_format('hi %s', 'there'); // "hi there"
    # str_format('hi %(first)s', {first:'Terence', last:'Honles'});
    # // "hi Terence"
    #
    # Note:
    #  - only %s and %(name)s formats are supported
    #  - format can be attached to the string class:
    #      String.prototype.format = (args...) ->
    #          str_format([this, args...]...)
    #
    #      'hi %s from %s'.format('there', 'Seattle');

    counter = 0
    dict = args[0]
    replace = (_, name) ->
       if name? then return dict[name] else return args[counter++]

    return string.replace(_format_pattern, replace)
