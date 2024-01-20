local M = {}

function M.addCurrentWin()
    table.insert(_G.termutils.termWindow, vim.fn.winnr())
end

function M.removeCurrentWin()
    local winnr = vim.fn.winnr()
    for i, win in ipairs(_G.termutils.termWindow) do
        if win == winnr then
            table.remove(_G.termutils.termWindow, i)
            break
        end
    end
end

function M.removeNumbers()
    vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*",
        command = [[set norelativenumber nonumber]],
    })
end

function M.rememberWindow()
    vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*",
        callback = M.addCurrentWin,
    })

    vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*",
        callback = M.removeCurrentWin,
    })
end

function M.startinsert()
    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        pattern = "term://*",
        command = "startinsert",
    })
end

function M.allBufs()
    ---@diagnostic disable-next-line: param-type-mismatch
    local maxBuf = vim.fn.bufnr('$')
    local out = {}
    for buf = 1, maxBuf do
        table.insert(out, buf)
    end
    return out
end

function M.filterBufsByType(type, bufs)
    return vim.tbl_filter(function(buf)
        return vim.fn.bufexists(buf) and vim.fn.getbufvar(buf, '&buftype', nil) == type
    end, bufs)
end

return M
