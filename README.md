
# Chance
*A library for generating random stuff*

**Importing with [Neon](https://github.com/Belkworks/NEON)**:
```lua
Chance = NEON:github('belkworks', 'chance')
```

## Example
```lua
RNG = Chance(os.time())

coin = RNG:coin() -- 'heads' or 'tails'
bool = RNG:bool() -- true or false
num = RNG:number(1, 10) -- integer
```
