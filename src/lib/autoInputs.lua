return {
    {
        pattern = "<100x>? yy zz",
        name = "keyboard",
        port = 2
    },
    {
        pattern = "E? xx yy",
        name = "pitchBend",
        value = "y*128 + x",
        port = 2
    },
    {
        pattern = "B? 01 xx",
        name = "modulation",
        port = 2
    },
    {
        pattern = "B? 40 xx",
        name = "sustain",
        port = 2
    },
    {
        pattern = "D? xx ??",
        name = "channelPressure",
        port = 2
    },
    {
        pattern = "B? 0B xx",
        name = "expression",
        port = 2
    },
    {
        pattern = "B0 44 xx",
        name = "footSwitch",
        port = 2
    }
}
