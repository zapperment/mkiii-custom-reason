local function truncate(x)
    return x < 0 and math.ceil(x) or math.floor(x)
end

return {
    truncate = truncate
}
