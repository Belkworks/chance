local charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
local toCharArray
toCharArray = function(Str)
  if 'table' == type(Str) then
    return Str
  end
  if 'string' ~= type(Str) then
    return 
  end
  local _accum_0 = { }
  local _len_0 = 1
  for i = 1, #Str do
    _accum_0[_len_0] = Str:sub(i, i)
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
local charlist = toCharArray(charset)
local default
default = function(Params, Key, Value)
  if 'table' ~= type(Params) then
    return 
  end
  if Params[Key] == nil then
    Params[Key] = Value
  end
end
local indexOf
indexOf = function(Table, Value)
  for I, V in pairs(Table) do
    if V == Value then
      return I
    end
  end
end
local Days = {
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
}
local Months = {
  'January',
  'Feburary',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
}
local Chance
do
  local _class_0
  local _base_0 = {
    bool = function(self)
      return 1 == self:number(0, 1)
    end,
    number = function(self, A, B)
      local AN = tonumber(A)
      local BN = tonumber(B)
      if AN == BN then
        return AN
      end
      if AN > BN then
        local temp = AN
        BN = AN
        AN = temp
      end
      if AN and BN then
        return self.source:NextInteger(AN, BN)
      end
      assert('table' == type(A), 'invalid parameter object passed to Chance.number')
      return self:number(A.lower, A.upper)
    end,
    char = function(self, list)
      if list == nil then
        list = charlist
      end
      if 'string' == type(list) then
        list = toCharArray(list)
      end
      assert('table' == type(list), 'invalid list passed to Chance.char')
      return list[self:number(1, #list)]
    end,
    string = function(self, Params)
      if Params == nil then
        Params = { }
      end
      default(Params, 'charset', charset)
      default(Params, 'length', 16)
      local list = charlist
      local length = #list
      if Params.charset ~= charset then
        list = toCharArray(Params.charset)
      end
      return table.concat(self:n(self.char, Params.length, list))
    end,
    format = function(self, String)
      local format = toCharArray(String)
      assert(format, 'invalid format string passed to Chance.format')
      local result = ''
      local caps = toCharArray('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
      local letters = toCharArray('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
      for _index_0 = 1, #format do
        local char = format[_index_0]
        result = result .. (function()
          local _exp_0 = char
          if 'X' == _exp_0 then
            return self:char(caps)
          elseif '*' == _exp_0 then
            return self:char()
          elseif 'N' == _exp_0 then
            return self:number(0, 9)
          elseif 'H' == _exp_0 then
            return string.format('%X', self:number(0, 15))
          elseif 'A' == _exp_0 then
            return self:char(letters)
          else
            return char
          end
        end)()
      end
      return result
    end,
    month = function(self)
      return self:pickone(Months)
    end,
    day = function(self)
      return self:pickone(Days)
    end,
    ampm = function(self)
      return self:pickone({
        'am',
        'pm'
      })
    end,
    millisecond = function(self)
      return self:number(0, 999)
    end,
    second = function(self)
      return self:number(0, 59)
    end,
    minute = function(self)
      return self:number(0, 59)
    end,
    hour = function(self, Params)
      if Params == nil then
        Params = { }
      end
      default(Params, 'twentyfour', false)
      return self:number(1, Params.twentyfour and 24 or 12)
    end,
    coin = function(self)
      return self:pickone({
        'heads',
        'tails'
      })
    end,
    dice = function(self, max)
      if max == nil then
        max = 6
      end
      return self:number(1, max)
    end,
    rpg = function(self, str, Params)
      if Params == nil then
        Params = { }
      end
      default(Params, 'sum', false)
      local num, max = str:match('(%d+)d(%d+)')
      assert(num and max, 'invalid string passed to Chance.rpg')
      assert(tonumber(max) > 1, 'invalid max passed to Chance.rpg')
      local result = self:n(self.dice, num, max)
      if not Params.sum then
        return result
      end
      local total = 0
      for _index_0 = 1, #result do
        local n = result[_index_0]
        total = total + n
      end
      return total
    end,
    pad = function(self, str, len, char)
      if char == nil then
        char = 0
      end
      local s = tostring(char)
      assert(s ~= 0, 'invalid char passed to Chance.pad')
      while #str < len do
        str = s .. char
      end
      return str
    end,
    prefix = function(self, str, F, ...)
      return tostring(str) .. (function(...)
        local _exp_0 = type(F)
        if 'function' == _exp_0 then
          return F(self, ...)
        else
          return tostring(F)
        end
      end)(...)
    end,
    n = function(self, F, N, ...)
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, N do
        _accum_0[_len_0] = F(self, ...)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    capitalize = function(self, str)
      return str:sub(1, 1):upper() .. str:sub(2)
    end,
    plural = function(self, str, n)
      return str .. (function()
        if n == 1 then
          return ''
        else
          return 's'
        end
      end)()
    end,
    pickone = function(self, array)
      assert('table' == type(array), 'invalid list passed to Chance.pickone')
      local len = #array
      if len == 0 then
        return 
      end
      if len == 1 then
        return array[1]
      end
      return array[self:number(1, len)]
    end,
    pickset = function(self, array, quantity)
      if quantity == nil then
        quantity = 1
      end
      assert('table' == type(array), 'invalid list passed to Chance.pickset')
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, quantity do
        _accum_0[_len_0] = self:pickone(array)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    unique = function(self, F, N, ...)
      local result = { }
      for i = 1, N do
        local val = F(self, ...)
        local z = 0
        while indexOf(result, val) do
          val = F(self, ...)
          z = z + 1
          if z > self.__class.uniqueMaxAttempts then
            break
          end
        end
        table.insert(result, val)
      end
      return result
    end,
    shuffle = function(self, array)
      assert('table' == type(array), 'invalid list passed to Chance.shuffle')
      local clone
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #array do
          local v = array[_index_0]
          _accum_0[_len_0] = v
          _len_0 = _len_0 + 1
        end
        clone = _accum_0
      end
      for i = #clone, 1, -1 do
        local r = self:number(1, i)
        local n = clone[r]
        clone[r] = clone[i]
        clone[i] = n
      end
      return clone
    end,
    reseed = function(self, Seed)
      if Seed == nil then
        Seed = 0
      end
      assert('number' == type(Seed), 'invalid seed number passed to Chance.reseed')
      if Random then
        self.source = Random.new(Seed)
      else
        math.randomseed(Seed)
        math.random()
        self.source = {
          NextInteger = function(self, min, max)
            return math.floor(0.5 + self:NextNumber(min, max))
          end,
          NextNumber = function(self, min, max)
            if min == nil then
              min = 0
            end
            if max == nil then
              max = 1
            end
            return min + math.random() * (max - min)
          end
        }
      end
    end,
    weighted = function(self, Choices, Weights)
      assert('table' == type(Choices), 'invalid list passed to Chance.weighted')
      assert('table' == type(Weights), 'invalid weights passed to Chance.weighted')
      assert(#Choices == #Weights, 'weights and list must be same length!')
      local sum = 0
      for _index_0 = 1, #Weights do
        local w = Weights[_index_0]
        sum = sum + w
      end
      local num = sum * self.source:NextNumber()
      local total = 0
      local lastGoodIdx = -1
      local chosenIdx = 0
      for i, choice in pairs(Choices) do
        local val = Weights[i]
        total = total + val
        if val > 0 then
          if num <= total then
            chosenIdx = i
            break
          end
          lastGoodIdx = i
        end
        if i == #Weights then
          chosenIdx = lastGoodIdx
        end
      end
      return Choices[chosenIdx]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, Seed)
      return self:reseed(Seed)
    end,
    __base = _base_0,
    __name = "Chance"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.uniqueMaxAttempts = 100
  Chance = _class_0
  return _class_0
end
