return {
    textLabel = {
        padding = {
            x = 8,
            y = 5
        },
        color = {
            default = {0, 0, 0},
        },
        font = love.graphics.newFont(20)
    },
    textButton = {
        padding = {
            x = 8,
            y = 5
        },
        cornerRadius = 5,
        background = {
            color = {
                default = {1, 1, 1},
                active = {1, 1, 0.4},
                hovered = {1, 1, 0.8},
                pressed = {0, 0, 0}
            },
        },
        text = {
            color = {
                default = {0, 0, 0},
                active = {0, 0, 0},
                hovered = {0, 0, 0},
                pressed = {1, 1, 1}
            },
            font = love.graphics.newFont(20)
        },
        outline = {
            color = {
                default = {0, 0, 0},
                active = {0, 0, 0},
                hovered = {0, 0, 0},
                pressed = {0, 0, 0}
            },
            width = 2
        }
    },
    inlineTextbox = {
        padding = {
            x = 8,
            y = 5
        },
        cornerRadius = 5,
        background = {
            color = {
                default = {1, 1, 1},
                active = {1, 1, 0.4},
                hovered = {1, 1, 0.8}
            },
        },
        text = {
            color = {
                default = {0, 0, 0},
                active = {0, 0, 0},
                hovered = {0, 0, 0}
            },
            font = love.graphics.newFont(20)
        },
        cursor = {
            color = {0, 0, 0},
            width = 1,
            blinkSpeed = 1
        },
        alttext = {
            color = {0.6, 0.6, 0.6},
            font = love.graphics.newFont(20)
        },
        scrollbar = {
            color = {0, 0, 0, 0.4},
            width = 4,
        },
        outline = {
            color = {
                default = {0, 0, 0},
                active = {0, 0, 0},
                hovered = {0, 0, 0},
                pressed = {0, 0, 0}
            },
            width = 2
        }
    },
    scrollableList = {
        padding = {
            x = 8,
            y = 5
        },
        cornerRadius = 5,
        background = {
            color = {
                default = {1, 1, 1},
                active = {1, 1, 0.4},
                hovered = {1, 1, 0.8}
            },
        },
        text = {
            color = {
                default = {0, 0, 0},
                active = {0, 0, 0},
                hovered = {0, 0, 0}
            },
            font = love.graphics.newFont(20)
        },
        cursor = {
            color = {0, 0, 0},
            width = 1,
            blinkSpeed = 1
        },
        alttext = {
            color = {0.6, 0.6, 0.6},
            font = love.graphics.newFont(20)
        },
        scrollbar = {
            color = {0, 0, 0, 0.4},
            width = 4,
        },
        outline = {
            color = {
                default = {0, 0, 0},
                active = {0, 0, 0},
                hovered = {0, 0, 0},
                pressed = {0, 0, 0}
            },
            width = 2
        }
    }
}