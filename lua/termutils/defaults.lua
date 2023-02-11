local M = {}

M.Orientation = {
    VERT  = 0,
    HORIZ = 1,
    AUTO  = 2,
}

M.defaultOpts = {
    removeNumbers      = true,
    startinsert        = true,
    smartClose         = true,
    defaultOrientation = M.Orientation.AUTO,
    charRatio          = 0.5,
}

function M.extend(tbl)
    return tbl and vim.tbl_extend("force", M.defaultOpts, tbl) or M.defaultOpts
end

return M
