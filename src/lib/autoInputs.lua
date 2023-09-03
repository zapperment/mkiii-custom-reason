return {{
    name = "keyboard",
    pattern = "<100x>? yy zz",
    port = 2
}, {
    name = "pitchBendWheel",
    pattern = "E? xx yy",
    value = "y*128 + x",
    port = 2
}, {
    name = "modulationWheel",
    pattern = "B? 01 xx",
    port = 2
}, {
    name = "sustainPedal",
    pattern = "B? 40 xx",
    port = 2
}, {
    name = "channelPressure",
    pattern = "D? xx ??",
    port = 2
}, {
    name = "expressionPedal",
    pattern = "B? 0B xx",
    port = 2
}, {
    name = "footSwitch",
    pattern = "B0 44 xx",
    port = 2
}, {
    name = "trackRightButton",
    pattern = "bF 67 ?<???x>",
    port = 1
}, {
    name = "trackLeftButton",
    pattern = "bF 66 ?<???x>",
    port = 1
}, {
    name = "loopButton",
    pattern = "bF 74 ?<???x>",
    port = 1
}, {
    name = "rewindButton",
    pattern = "bF 70 ?<???x>",
    port = 1
}, {
    name = "fastForwardButton",
    pattern = "bF 71 ?<???x>",
    port = 1
}, {
    name = "stopButton",
    pattern = "bF 72 ?<???x>",
    port = 1
}, {
    name = "playButton",
    pattern = "bF 73 ?<???x>",
    port = 1
}, {
    name = "recordButton",
    pattern = "bF 75 ?<???x>",
    port = 1
}, {
    name = "optionsButton",
    pattern = "bF 5A ?<???x>",
    port = 1
}, {
    name = "clipUpButton",
    pattern = "bF 55 xx",
    port = 1
}, {
    name = "clipDownButton",
    pattern = "bF 56 xx",
    port = 1
}, {
    name = "overdubButton",
    pattern = "bF 53 xx",
    port = 1
}, {
    name = "altTakeButton",
    pattern = "bF 54 xx",
    port = 1
}, {
    name = "pad1",
    pattern = "9F 70 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad2",
    pattern = "9F 71 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad3",
    pattern = "9F 72 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad4",
    pattern = "9F 73 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad5",
    pattern = "9F 74 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad6",
    pattern = "9F 75 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad7",
    pattern = "9F 76 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad8",
    pattern = "9F 77 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad9",
    pattern = "9F 60 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad10",
    pattern = "9F 61 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad11",
    pattern = "9F 62 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad12",
    pattern = "9F 63 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad13",
    pattern = "9F 64 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad14",
    pattern = "9F 65 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad15",
    pattern = "9F 66 xx",
    value = "greaterThanZero(x)",
    port = 1
}, {
    name = "pad16",
    pattern = "9F 67 xx",
    value = "greaterThanZero(x)",
    port = 1
}}
