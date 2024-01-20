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
--- that terminal, otherwise close nvim.
---
--- If the terminal no longer exists, return to the alternative buffer
--- If no alternative buffer exists, return to the last created buffer
--- If no more buffers are available, close nvim.
---
--- Various options can be provided via the `opts` table (which is itself optional)
---
--- If the current buffer _is_ a terminal, closes the terminal and return to the
--- last buffer in jump list. Use the `terminal_close_fn` from `opts` and returns
--- it's value. If not provided, terminal is closed with `:bw!`.
---
--- If `editor_close_fn` is provided in `opts`, `smartClose` will call and
--- return it's value if it needs to exit nvim. By default it uses `:x`.
---
--- If `buffer_close_fn` is in `opts`, `smartClose` it will be used to close the
--- buffer spawned from the terminal. `buffer_close_fn` takes an optional
--- integer indicating which buffer needs closing, if it's nil, close current buffer.
--- Default close is write (if modifiable) then `:bw`.
---
--- NOTE: By default only the terminal is closed with `!`, so ` work shouldn't be lost.
---
---@param opts? table
---@return unknown|nil
function M.smartClose(opts)
    assert(M._opts.smartClose, "Cannot call termutils.smartClose if smartClose option is set to false in setup")

    if vim.bo.buftype == "terminal" then
        return utils.getOpt(opts, 'terminal_close_fn', function()
            vim.cmd [[:bw!]]
        end)()
    end
    local winnr = vim.fn.winnr()
    if vim.tbl_contains(_G.termutils.termWindow, winnr) then
        local terminals = utils.filterBufsByType("terminal", utils.allBufs())
        local this_bufnr = vim.fn.bufnr()
        local buf = (function()
            -- if there are is a terminal buffers to fall back, use it
            if (terminals ~= nil and #terminals ~= 0 and vim.fn.bufexists(terminals[1])) then
                return terminals[1]
            end

            -- otherwise pick something sensible

            -- alternative buffer?
            do
                local buf = vim.fn.bufnr('#') ---@diagnostic disable-line: param-type-mismatch
                if buf ~= -1 and vim.fn.bufexists(buf) then
                    return buf
                end
            end

            -- last buffer?
            ---@diagnostic disable-next-line: param-type-mismatch
            for buf = vim.fn.bufnr('$'), 0, -1 do
                if buf ~= this_bufnr and vim.fn.bufexists(buf) then
                    return buf
                end
            end
            -- the nvr buffer we're about to close is the last buffer there is, so just close nvim
            return -1
        end)()

        local function default_exit(b)
            if b ~= nil then
                if vim.bo[b].modifiable then
                    local alt = utils.saveAlternative()
                    local current = vim.fn.bufnr()
                    vim.cmd (tostring(b) .. "bufdo w")
                    vim.cmd("buffer " .. tostring(current))
                    utils.restoreAlternative(alt)
                end
                vim.cmd("bw " .. tostring(b))
            else
                vim.cmd [[:w|bw]]
            end
        end

        -- we found the buffer to go back to and the current buffer is valid
        -- so we go to the target buffer and close the old one (bwipe it, because we've "closed" that instance)
        if buf ~= -1 and vim.fn.bufexists(buf) and vim.fn.bufexists(this_bufnr) then
            vim.cmd("buffer " .. tostring(buf))
            return utils.getOpt(opts, 'buffer_close_fn', default_exit)(this_bufnr)
        else
            return utils.getOpt(opts, 'buffer_close_fn', default_exit)()
        end
    end

    return utils.getOpt(opts, 'editor_close_fn', function()
        vim.cmd [[:x]]
    end)()
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
            minor = 6,
            patch = 0,
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
