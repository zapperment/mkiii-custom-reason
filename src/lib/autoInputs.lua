return {
    {
        name = "keyboard",
        pattern = "<100x>? yy zz",
        port = 2
    },
    {
        name = "pitchBendWheel",
        pattern = "E? xx yy",
        value = "y*128 + x",
        port = 2
    },
    {
        name = "modulationWheel",
        pattern = "B? 01 xx",
        port = 2
    },
    {
        name = "sustainPedal",
        pattern = "B? 40 xx",
        port = 2
    },
    {
        name = "channelPressure",
        pattern = "D? xx ??",
        port = 2
    },
    {
        name = "expressionPedal",
        pattern = "B? 0B xx",
        port = 2
    },
    {
        name = "footSwitch",
        pattern = "B0 44 xx",
        port = 2
    },
    {
        name = "trackRightButton",
        pattern = "bF 67 ?<???x>",
        port = 1
    },
    {
        name = "trackLeftButton",
        pattern = "bF 66 ?<???x>",
        port = 1
    },
    {
        name = "loopButton",
        pattern = "bF 74 ?<???x>",
        port = 1
    },
    {
        name = "rewindButton",
        pattern = "bF 70 ?<???x>",
        port = 1
    },
    {
        name = "fastForwardButton",
        pattern = "bF 71 ?<???x>",
        port = 1
    },
    {
        name = "stopButton",
        pattern = "bF 72 ?<???x>",
        port = 1
    },
    {
        name = "playButton",
        pattern = "bF 73 ?<???x>",
        port = 1
    },
    {
        name = "recordButton",
        pattern = "bF 75 ?<???x>",
        port = 1
    },
    {
        name = "optionsButton",
        pattern = "bF 5A ?<???x>",
        port = 1
    },
    {
        name = "clipUpButton",
        pattern = "bF 55 xx",
        port = 1
    },
    {
        name = "clipDownButton",
        pattern = "bF 56 xx",
        port = 1
    }
}
