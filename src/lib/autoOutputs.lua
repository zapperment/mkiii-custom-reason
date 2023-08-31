return {{
    name = "optionsButton",
    pattern = "BF 5A xx",
    x = "value*(buttonColourWhite)",
    port = 1
}, {
    name = "rewindButton",
    pattern = "BF 70 xx",
    x = "value*(buttonColourWhite)",
    port = 1
}, {
    name = "fastForwardButton",
    pattern = "BF 71 xx",
    x = "value*(buttonColourWhite)",
    port = 1
}, {
    name = "stopButton",
    pattern = "BF 72 xx",
    x = "value*(buttonColourWhite)",
    port = 1
}, {
    name = "playButton",
    pattern = "BF 73 xx",
    x = "(value*(buttonColourGreen-buttonColourDimGreen))+buttonColourDimGreen",
    port = 1
}, {
    name = "loopButton",
    pattern = "BF 74 xx",
    x = "value*(buttonColourWhite)",
    port = 1
}, {
    name = "recordButton",
    pattern = "BF 75 xx",
    x = "(value*(buttonColourRed-buttonColourDimRed))+buttonColourDimRed",
    port = 1
}}
