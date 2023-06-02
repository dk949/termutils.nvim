local utils = require("termutils.utils")
local defaults = require("termutils.defaults")
local M = {
    _opts = {},
    Orientation = defaults.Orientation
}

function M.startTerminal(orientation)
    local o = orientation or M._opts.defaultOrientation
    local w = vim.api.nvim_win_get_width(0)
    local h = vim.api.nvim_win_get_height(0)
    if o == M.Orientation.HORIZ or (o == M.Orientation.AUTO and (w * M._opts.charRatio) <= h) then
        vim.cmd [[split]]
    else
        vim.cmd [[vert split]]
    end
    vim.cmd [[term]]
    if M._opts.startinsert then vim.cmd [[startinsert]] end
end

function M.smartClose()
    ---@diagnostic disable-next-line: param-type-mismatch
    assert(M._opts.smartClose, "Cannot call termutils.smartClose if smartClose option is set to false")
    local winnr = vim.fn.winnr()

    if vim.bo.buftype ~= "terminal" and vim.tbl_contains(_G.termutils.termWindow, winnr) then
        local terminals = utils.filterBufsByType("terminal", utils.allBufs())
        assert(terminals ~= nil and #terminals ~= 0, "Terminals is empty")
        local bufnr = vim.fn.bufnr()
        vim.cmd("buffer " .. tostring(terminals[1]))
        vim.cmd("bdelete " .. tostring(bufnr))
    else
        vim.api.nvim_feedkeys("ZZ", 'n', false)
    end
end

function M.saveMode()
    vim.b.term_utils_last_mode = vim.fn.mode()
end

function M.getMode()
    return vim.b.term_utils_last_mode
end

function M.setup(options)
    _G.termutils = { termWindow = {} }
    M._opts = defaults.extend(options)
    if M._opts.removeNumbers then utils.removeNumbers() end
    if M._opts.startinsert then utils.startinsert() end
    if M._opts.smartClose then utils.rememberWindow() end
end

return M
