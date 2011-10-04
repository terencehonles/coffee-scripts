###*
 @license Copyright 2011 Terence Honles
 Dual licensed under the MIT & GPL licenses
 see: https://github.com/terencehonles/coffee-scripts
###
#
# md5 (Message-Digest Algorithm)
#
# see: http://www.webtoolkit.info/javascript-md5.html
# - ripped here: http://css-tricks.com/snippets/javascript/javascript-md5/
# - and here: http://plugins.jquery.com/project/md5
#
# see: http://www.myersdaily.org/joseph/javascript/md5-text.html

# bitmath
rotate_left = (val, shift) -> return val << shift | val >>> (32 - shift)

addu = (x, y) ->
    # masks
    _c0 = 0xC0000000
    _80 = 0x80000000
    _40 = 0x40000000
    _3f = 0x3FFFFFFF

    x4 = x & _40
    y4 = y & _40
    x8 = x & _80
    y8 = y & _80
    result = ((x & _3f) + (y & _3f)) ^ x8 ^ y8

    if x4 & y4
        return result ^ _80

    if x4 | y4
        if result & _40
            return result ^ _c0
        else
            return result ^ _40
    else
        return result

# simple bitwise functions
f = (x, y, z) -> return (x & y) | (~x & z)
g = (x, y, z) -> return (x & z) | (y & ~z)
h = (x, y, z) -> return (x ^ y ^ z)
i = (x, y, z) -> return (y ^ (x | ~z))

# we're using a higher level language... let's take advantage of it
combined = (fun) ->
    return (a, b, c, d, x, s, ac) ->
        return addu(rotate_left(addu(a, addu(addu(fun(b, c, d), x), ac)), s), b)

[ff, gg, hh, ii] = (combined(fun) for fun in [f, g, h, i])

# turn a string into an array of words
word_array = (string) ->
    count = 0
    len = string.length
    num_words = (1 + ((len + 8) >> 6)) * 16
    result = Array(num_words)

    while count < len
        result[count >> 2] |= string.charCodeAt(count) << ((count % 4) * 8)
        count++

    result[len >> 2] |= 0x80 << ((len % 4) * 8)
    result[num_words - 2] = len << 3
    result[num_words - 1] = len >>> 29

    return result

# turns a value into its little-endian hex representation (filling zeroes)
word_as_hex = (value) ->
    result = Array(4)
    for count in [0...4]
        chunk = ((value >>> (count * 8)) & 255).toString(16)
        result[count] = if chunk.length == 2 then chunk else "0#{chunk}"

    return result.join('')

this.md5 = (string) ->
    # s-matrix
    [s11, s12, s13, s14] = [7, 12, 17, 22]
    [s21, s22, s23, s24] = [5, 9,  14, 20]
    [s31, s32, s33, s34] = [4, 11, 16, 23]
    [s41, s42, s43, s44] = [6, 10, 15, 21]

    [a, b, c, d] = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476]

    # make sure we are dealing with UTF-8 encoded strings
    words = word_array(unescape(encodeURIComponent(string)))
    offset = 0
    len = words.length

    while offset < len
        aa = a
        bb = b
        cc = c
        dd = d

        a = ff(a, b, c, d, words[offset + 0], s11, 0xD76AA478)
        d = ff(d, a, b, c, words[offset + 1], s12, 0xE8C7B756)
        c = ff(c, d, a, b, words[offset + 2], s13, 0x242070DB)
        b = ff(b, c, d, a, words[offset + 3], s14, 0xC1BDCEEE)

        a = ff(a, b, c, d, words[offset + 4], s11, 0xF57C0FAF)
        d = ff(d, a, b, c, words[offset + 5], s12, 0x4787C62A)
        c = ff(c, d, a, b, words[offset + 6], s13, 0xA8304613)
        b = ff(b, c, d, a, words[offset + 7], s14, 0xFD469501)

        a = ff(a, b, c, d, words[offset + 8], s11, 0x698098D8)
        d = ff(d, a, b, c, words[offset + 9], s12, 0x8B44F7AF)
        c = ff(c, d, a, b, words[offset + 10], s13, 0xFFFF5BB1)
        b = ff(b, c, d, a, words[offset + 11], s14, 0x895CD7BE)

        a = ff(a, b, c, d, words[offset + 12], s11, 0x6B901122)
        d = ff(d, a, b, c, words[offset + 13], s12, 0xFD987193)
        c = ff(c, d, a, b, words[offset + 14], s13, 0xA679438E)
        b = ff(b, c, d, a, words[offset + 15], s14, 0x49B40821)

        a = gg(a, b, c, d, words[offset + 1], s21, 0xF61E2562)
        d = gg(d, a, b, c, words[offset + 6], s22, 0xC040B340)
        c = gg(c, d, a, b, words[offset + 11], s23, 0x265E5A51)
        b = gg(b, c, d, a, words[offset + 0], s24, 0xE9B6C7AA)

        a = gg(a, b, c, d, words[offset + 5], s21, 0xD62F105D)
        d = gg(d, a, b, c, words[offset + 10], s22, 0x2441453)
        c = gg(c, d, a, b, words[offset + 15], s23, 0xD8A1E681)
        b = gg(b, c, d, a, words[offset + 4], s24, 0xE7D3FBC8)

        a = gg(a, b, c, d, words[offset + 9], s21, 0x21E1CDE6)
        d = gg(d, a, b, c, words[offset + 14], s22, 0xC33707D6)
        c = gg(c, d, a, b, words[offset + 3], s23, 0xF4D50D87)
        b = gg(b, c, d, a, words[offset + 8], s24, 0x455A14ED)

        a = gg(a, b, c, d, words[offset + 13], s21, 0xA9E3E905)
        d = gg(d, a, b, c, words[offset + 2], s22, 0xFCEFA3F8)
        c = gg(c, d, a, b, words[offset + 7], s23, 0x676F02D9)
        b = gg(b, c, d, a, words[offset + 12], s24, 0x8D2A4C8A)

        a = hh(a, b, c, d, words[offset + 5], s31, 0xFFFA3942)
        d = hh(d, a, b, c, words[offset + 8], s32, 0x8771F681)
        c = hh(c, d, a, b, words[offset + 11], s33, 0x6D9D6122)
        b = hh(b, c, d, a, words[offset + 14], s34, 0xFDE5380C)

        a = hh(a, b, c, d, words[offset + 1], s31, 0xA4BEEA44)
        d = hh(d, a, b, c, words[offset + 4], s32, 0x4BDECFA9)
        c = hh(c, d, a, b, words[offset + 7], s33, 0xF6BB4B60)
        b = hh(b, c, d, a, words[offset + 10], s34, 0xBEBFBC70)

        a = hh(a, b, c, d, words[offset + 13], s31, 0x289B7EC6)
        d = hh(d, a, b, c, words[offset + 0], s32, 0xEAA127FA)
        c = hh(c, d, a, b, words[offset + 3], s33, 0xD4EF3085)
        b = hh(b, c, d, a, words[offset + 6], s34, 0x4881D05)

        a = hh(a, b, c, d, words[offset + 9], s31, 0xD9D4D039)
        d = hh(d, a, b, c, words[offset + 12], s32, 0xE6DB99E5)
        c = hh(c, d, a, b, words[offset + 15], s33, 0x1FA27CF8)
        b = hh(b, c, d, a, words[offset + 2], s34, 0xC4AC5665)

        a = ii(a, b, c, d, words[offset + 0], s41, 0xF4292244)
        d = ii(d, a, b, c, words[offset + 7], s42, 0x432AFF97)
        c = ii(c, d, a, b, words[offset + 14], s43, 0xAB9423A7)
        b = ii(b, c, d, a, words[offset + 5], s44, 0xFC93A039)

        a = ii(a, b, c, d, words[offset + 12], s41, 0x655B59C3)
        d = ii(d, a, b, c, words[offset + 3], s42, 0x8F0CCC92)
        c = ii(c, d, a, b, words[offset + 10], s43, 0xFFEFF47D)
        b = ii(b, c, d, a, words[offset + 1], s44, 0x85845DD1)

        a = ii(a, b, c, d, words[offset + 8], s41, 0x6FA87E4F)
        d = ii(d, a, b, c, words[offset + 15], s42, 0xFE2CE6E0)
        c = ii(c, d, a, b, words[offset + 6], s43, 0xA3014314)
        b = ii(b, c, d, a, words[offset + 13], s44, 0x4E0811A1)

        a = ii(a, b, c, d, words[offset + 4], s41, 0xF7537E82)
        d = ii(d, a, b, c, words[offset + 11], s42, 0xBD3AF235)
        c = ii(c, d, a, b, words[offset + 2], s43, 0x2AD7D2BB)
        b = ii(b, c, d, a, words[offset + 9], s44, 0xEB86D391)

        a = addu(a, aa)
        b = addu(b, bb)
        c = addu(c, cc)
        d = addu(d, dd)
        offset += 16

    return word_as_hex(a) + word_as_hex(b) + word_as_hex(c) + word_as_hex(d)
