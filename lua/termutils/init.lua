local utils = require("termutils.utils")
local defaults = require("termutils.defaults")
---@alias Orientation
---| 0 Orientation.VERT
---| 1 Orientation.HORIZ
---| 2 Orientation.AUTO

local M = {
    _opts = {},
    Orientation = defaults.Orientation
}



---Create a new terminal in a split in the direction of `orientation`
---
--- When using Orientation.AUTO, split is in the direcion with most space
--- e.g. with one window on a 16:9 screen open vertical split
---      with one window on a 9:16 screen (vertically mounted) open hirizontal split
---@param orientation Orientation
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

--- If the current buffer was opened on the same window as a terminal, return to
--- that terminal, otherwise close nvim
---
--- If the terminal no longer exists, return to the alternative buffer
--- If no alternative buffer exists, return to the last created buffer
--- If no more buffers are available, close nvim.
function M.smartClose()
    ---@diagnostic disable-next-line: param-type-mismatch
    assert(M._opts.smartClose, "Cannot call termutils.smartClose if smartClose option is set to false in setup")
    local winnr = vim.fn.winnr()

    if vim.bo.buftype ~= "terminal" and vim.tbl_contains(_G.termutils.termWindow, winnr) then
        local terminals = utils.filterBufsByType("terminal", utils.allBufs())
        local this_bufnr = vim.fn.bufnr()
        local buf = (function()
            -- if there are is a terminal buffers to fall back, use it
            if (terminals ~= nil and #terminals ~= 0) then return terminals[1] end

            -- otherwise pick something sensible

            -- alternative buffer?
            do
                local buf = vim.fn.bufnr('#') ---@diagnostic disable-line: param-type-mismatch
                if buf ~= -1 then return buf end
            end

            -- last buffer?
            ---@diagnostic disable-next-line: param-type-mismatch
            for buf = vim.fn.bufnr('$'), 0, -1 do
                if buf ~= this_bufnr then return buf end
            end
            -- the nvr buffer we're about to close is the last buffer there is, so just close nvim
            return -1
        end)()
        if buf ~= -1 then
            vim.cmd("buffer " .. tostring(buf))
            vim.cmd("bdelete " .. tostring(this_bufnr))
            return
        end
    end
    vim.api.nvim_feedkeys("ZZ", 'n', false)
end

function M.saveMode()
    vim.b.term_utils_last_mode = vim.fn.mode()
end

function M.getMode()
    return vim.b.term_utils_last_mode
end

--- Set up termutils
--- This function has to be called before any other functions can be used.
function M.setup(options)
    _G.termutils = {
        version = {
            major = 1,
            minor = 4,
            patch = 1,
        },
        termWindow = {}
    }
    M._opts = defaults.extend(options)
    if M._opts.removeNumbers then utils.removeNumbers() end
    if M._opts.startinsert then utils.startinsert() end
    if M._opts.smartClose then utils.rememberWindow() end
end

--- Register current window as a terminal window
---
--- NOTE: These are advanced functions for directly manipulating termutils state.
---       You shouldn't need to call them under normal circumstances.
---
--- When opening a terminal, the window will be registered automatically,
--- _unless_ TermOpen event does not fire. This can happen if `:term`
--- immediatley runs a command which opens a new nvim instance via nvr.
--- In that case, run this command before `:term` and `removeCurrentWin` after.
---
--- @see termutils.removeCurrentWin
function M.addCurrentWin()
    return utils.addCurrentWin()
end

--- Unregister current window as a terminal window
---
--- NOTE: This is a no-op if the current window is not registered
---
--- @see termutils.addCurrentWin()
function M.removeCurrentWin()
    return utils.removeCurrentWin()
end

return M
