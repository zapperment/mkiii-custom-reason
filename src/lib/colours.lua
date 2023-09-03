-- dec  hex   name
--   0   00   black
--   1   01   dark grey
--   2   02   grey
--   3   03   white
-- Colours 4-59 are grouped by fours, light, normal, mid and dark
--   4   04   light red
--   5   05   red
--   6   06   mid red
--   7   07   dark red
--   8   08   light orange
--   9   09   orange
--  10   0A   mid orange
--  11   0B   dark orange
--  12   0C   light yellow
--  13   0D   yellow 
--  14   0E   mid yellow
--  15   0F   dark yellow
--  16   10   light yellow green
--  17   11   yellow green
--  18   12   mid yellow green
--  19   13   dark yellow green
--  20   14   light green
--  21   15   green
--  22   16   mid green
--  23   17   dark green
--  24   18   light forest green
--  25   19   forest green
--  26   1A   mid forest green
--  27   1B   dark forest green
--  28   1C   light sea green
--  29   1D   sea green
--  30   1E   mid sea green
--  31   1F   dark sea green
--  32   20   light turquoise
--  33   21   turquoise
--  34   22   mid turquoise
--  35   23   dark turquoise
--  36   24   light sky blue
--  37   25   sky blue
--  38   26   mid sky blue
--  39   27   dark sky blue
--  40   28   light baby blue
--  41   29   baby blue
--  42   2A   mid baby blue
--  43   2B   dark baby blue
--  44   2C   light blue
--  45   2D   blue
--  46   2E   mid blue
--  47   2F   dark blue
--  48   30   light violet
--  49   31   violet
--  50   32   mid violet
--  51   33   dark violet
--  52   34   light magenta
--  53   35   magenta
--  54   36   mid magenta
--  55   37   dark magenta
--  56   38   light pink
--  57   39   pink
--  58   3A   mid pink
--  59   3B   dark pink
-- After colour 59, the colours are not grouped and seem 
-- to be in random order; apparently, they are mostly the
-- same as the grouped colors, so we just ignore them
--  60   3C   xxx
--  61   3D   xxx
--  62   3E   xxx
--  63   3F   xxx
--  64   40   xxx
--  65   41   xxx
--  66   42   xxx
--  67   43   xxx
--  68   44   xxx
--  69   45   xxx
--  70   46   xxx
--  71   47   xxx
--  72   48   xxx
--  73   49   xxx
--  74   4A   xxx
--  75   4B   xxx
--  76   4C   xxx
--  77   4D   xxx
--  78   4E   xxx
--  79   4F   xxx
--  80   50   xxx
--  81   51   xxx
--  82   52   xxx
--  83   53   xxx
--  84   54   xxx
--  85   55   xxx
--  86   56   xxx
--  87   57   xxx
--  88   58   xxx
--  89   59   xxx
--  90   5A   xxx
--  91   5B   xxx
--  92   5C   xxx
--  93   5D   xxx
--  94   5E   xxx
--  95   5F   xxx
--  96   60   xxx
--  97   61   xxx
--  98   62   xxx
--  99   63   xxx
-- 100   64   xxx
-- 101   65   xxx
-- 102   66   xxx
-- 103   67   xxx
-- 104   68   xxx
-- 105   69   xxx
-- 106   6A   xxx
-- 107   6B   xxx
-- 108   6C   xxx
-- 109   6D   xxx
-- 110   6E   xxx
-- 111   6F   xxx
-- 112   70   xxx
-- 113   71   xxx
-- 114   72   xxx
-- 115   73   xxx
-- 116   74   xxx
-- 117   75   xxx
-- 118   76   xxx
-- 119   77   xxx
-- 120   78   xxx
-- 121   79   xxx
-- 122   7A   xxx
-- 123   7B   xxx
-- 124   7C   xxx
-- 125   7D   xxx
-- 126   7E   xxx
-- 127   7F   xxx

return {
    black = {
        dec = 0,
        hex = "00"
    },
    darkGrey = {
        dec = 1,
        hex = "01"
    },
    grey = {
        dec = 2,
        hex = "02"
    },
    white = {
        dec = 3,
        hex = "03"
    },
    lightRed = {
        dec = 4,
        hex = "04"
    },
    red = {
        dec = 5,
        hex = "05"
    },
    midRed = {
        dec = 6,
        hex = "06"
    },
    darkRed = {
        dec = 7,
        hex = "07"
    },
    lightOrange = {
        dec = 8,
        hex = "08"
    },
    orange = {
        dec = 9,
        hex = "09"
    },
    midOrange = {
        dec = 10,
        hex = "0A"
    },
    darkOrange = {
        dec = 11,
        hex = "0B"
    },
    lightYellow = {
        dec = 12,
        hex = "0C"
    },
    yellow = {
        dec = 13,
        hex = "0D"
    },
    midYellow = {
        dec = 14,
        hex = "0E"
    },
    darkYellow = {
        dec = 15,
        hex = "0F"
    },
    lightYellowGreen = {
        dec = 16,
        hex = "10"
    },
    yellowGreen = {
        dec = 17,
        hex = "11"
    },
    midYellowGreen = {
        dec = 18,
        hex = "12"
    },
    darkYellowGreen = {
        dec = 19,
        hex = "13"
    },
    lightGreen = {
        dec = 20,
        hex = "14"
    },
    green = {
        dec = 21,
        hex = "15"
    },
    midGreen = {
        dec = 22,
        hex = "16"
    },
    darkGreen = {
        dec = 23,
        hex = "17"
    },
    lightForestGreen = {
        dec = 24,
        hex = "18"
    },
    forestGreen = {
        dec = 25,
        hex = "19"
    },
    midForestGreen = {
        dec = 26,
        hex = "1A"
    },
    darkForestGreen = {
        dec = 27,
        hex = "1B"
    },
    lightSeaGreen = {
        dec = 28,
        hex = "1C"
    },
    seaGreen = {
        dec = 29,
        hex = "1D"
    },
    midSeaGreen = {
        dec = 30,
        hex = "1E"
    },
    darkSeaGreen = {
        dec = 31,
        hex = "1F"
    },
    lightTurquoise = {
        dec = 32,
        hex = "20"
    },
    turquoise = {
        dec = 33,
        hex = "21"
    },
    midTurquoise = {
        dec = 34,
        hex = "22"
    },
    darkTurquoise = {
        dec = 35,
        hex = "23"
    },
    lightSkyBlue = {
        dec = 36,
        hex = "24"
    },
    skyBlue = {
        dec = 37,
        hex = "25"
    },
    midSkyBlue = {
        dec = 38,
        hex = "26"
    },
    darkSkyBlue = {
        dec = 39,
        hex = "27"
    },
    lightBabyBlue = {
        dec = 40,
        hex = "28"
    },
    babyBlue = {
        dec = 41,
        hex = "29"
    },
    midBabyBlue = {
        dec = 42,
        hex = "2A"
    },
    darkBabyBlue = {
        dec = 43,
        hex = "2B"
    },
    lightBlue = {
        dec = 44,
        hex = "2C"
    },
    blue = {
        dec = 45,
        hex = "2D"
    },
    midBlue = {
        dec = 46,
        hex = "2E"
    },
    darkBlue = {
        dec = 47,
        hex = "2F"
    },
    lightViolet = {
        dec = 48,
        hex = "30"
    },
    violet = {
        dec = 49,
        hex = "31"
    },
    midViolet = {
        dec = 50,
        hex = "32"
    },
    darkViolet = {
        dec = 51,
        hex = "33"
    },
    lightMagenta = {
        dec = 52,
        hex = "34"
    },
    magenta = {
        dec = 53,
        hex = "35"
    },
    midMagenta = {
        dec = 54,
        hex = "36"
    },
    darkMagenta = {
        dec = 55,
        hex = "37"
    },
    lightPink = {
        dec = 56,
        hex = "38"
    },
    pink = {
        dec = 57,
        hex = "39"
    },
    midPink = {
        dec = 58,
        hex = "3A"
    },
    darkPink = {
        dec = 59,
        hex = "3B"
    }
}
