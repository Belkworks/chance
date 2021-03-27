-- chance.moon
-- SFZILabs 2019

charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

toCharArray = (Str) ->
    return Str if 'table' == type Str
    return if 'string' ~= type Str
    [Str\sub i,i for i=1,#Str]

charlist = toCharArray charset

default = (Params, Key, Value) ->
    return if 'table' ~= type Params
    Params[Key] = Value if Params[Key] == nil

indexOf = (Table, Value) -> return I for I, V in pairs Table when V == Value

Days = {'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'}

Months = {'January', 'Feburary', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'}

class Chance
    @uniqueMaxAttempts: 100
    new: (Seed) => @reseed Seed
    -- Primitive
    bool: => 1 == @number 0, 1

    -- Number
    number: (A, B) => -- int: Lower (or table), Upper
        AN = tonumber A
        BN = tonumber B

        return AN if AN == BN

        if AN > BN
            temp = AN
            BN = AN
            AN = temp

        return @source\NextInteger AN, BN if AN and BN

        assert 'table' == type(A), 'invalid parameter object passed to Chance.number'

        @number A.lower, A.upper

    -- String
    char: (list = charlist) =>
        list = toCharArray list if 'string' == type list
        assert 'table' == type(list), 'invalid list passed to Chance.char'
        list[@number 1, #list]

    string: (Params = {}) =>
        default Params, 'charset', charset
        default Params, 'length', 16
        list = charlist
        length = #list
        if Params.charset ~= charset
            list = toCharArray Params.charset
        table.concat @n @char, Params.length, list

    format: (String) =>
        format = toCharArray String
        assert format, 'invalid format string passed to Chance.format'
        result = ''
        caps = toCharArray 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        letters = toCharArray 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        for char in *format
            result ..=  switch char
                when 'X' -- upper
                    @char caps
                when '*' -- charset
                    @char!
                when 'N' -- number
                    @number 0,9
                when 'H' -- hex
                    string.format '%X', @number 0, 15
                when 'A' -- upper and lower
                    @char letters
                else char
        result

    -- Time
    month: => @pickone Months
    day: => @pickone Days
    ampm: => @pickone {'am', 'pm'}
    millisecond: => @number 0, 999
    second: => @number 0, 59
    minute: => @number 0, 59
    hour: (Params = {}) =>
        default Params, 'twentyfour', false
        @number 1, Params.twentyfour and 24 or 12

    -- Util
    coin: => @pickone {'heads', 'tails'}
    dice: (max = 6) => @number 1, max

    rpg: (str, Params = {}) =>
        default Params, 'sum', false
        num, max = str\match '(%d+)d(%d+)'
        assert num and max, 'invalid string passed to Chance.rpg'
        assert tonumber(max) > 1, 'invalid max passed to Chance.rpg'
        result = @n @dice, num, max
        return result if not Params.sum
        total = 0
        total += n for n in *result
        total

    pad: (str, len, char = 0) =>
        s = tostring char
        assert s != 0, 'invalid char passed to Chance.pad'
        while #str < len
            str = s .. char
        str

    prefix: (str, F, ...) =>
        tostring(str) .. switch type F
            when 'function'
                F @, ...
            else tostring F

    n: (F, N, ...) => [F @, ... for i=1,N]
    capitalize: (str) => str\sub(1,1)\upper! .. str\sub 2
    plural: (str, n) => str .. if n == 1 then '' else 's' 

    pickone: (array) =>
        assert 'table' == type(array), 'invalid list passed to Chance.pickone'
        len = #array
        return if len == 0
        return array[1] if len == 1 
        array[@number 1, len]

    pickset: (array, quantity = 1) =>
        assert 'table' == type(array), 'invalid list passed to Chance.pickset'
        [@pickone array for i=1,quantity]

    unique: (F, N, ...) =>
        result = {}
        for i=1,N
            val = F @, ...
            z = 0
            while indexOf result, val
                val = F @, ...
                z += 1
                break if z > @@uniqueMaxAttempts
            table.insert result, val
        result 

    shuffle: (array) =>
        assert 'table' == type(array), 'invalid list passed to Chance.shuffle'
        clone = [v for v in *array]
        for i=#clone,1,-1 do
            r = @number 1, i
            n = clone[r]
            clone[r] = clone[i]
            clone[i] = n
        clone

    reseed: (Seed = 0) =>
        assert 'number' == type(Seed), 'invalid seed number passed to Chance.reseed'
        @source = if Random -- ROBLOX
            Random.new Seed
        else
            math.randomseed Seed
            math.random!
            {
                NextInteger: (min, max) =>
                    math.floor 0.5 + @NextNumber min, max
                NextNumber: (min = 0, max = 1) =>
                    min + math.random()*(max-min)
            }

    weighted: (Choices, Weights) =>
        assert 'table' == type(Choices), 'invalid list passed to Chance.weighted'
        assert 'table' == type(Weights), 'invalid weights passed to Chance.weighted'
        assert #Choices == #Weights, 'weights and list must be same length!'
        sum = 0
        sum += w for w in *Weights
        num = sum * @source\NextNumber!
        total = 0
        lastGoodIdx = -1
        chosenIdx = 0
        for i, choice in pairs Choices
            val = Weights[i]
            total += val
            if val > 0
                if num <= total
                    chosenIdx = i
                    break

                lastGoodIdx = i

            if i == #Weights
                chosenIdx = lastGoodIdx

        -- print chosenIdx
        Choices[chosenIdx]