local M = {}

function M.removeNumbers()
    vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*",
        command = [[set norelativenumber nonumber]],
    })
end

function M.rememberWindow()
    vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*",
        callback = function()
            table.insert(_G.termutils.termWindow, vim.fn.winnr())
        end
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
        return vim.fn.bufexists(buf) and vim.bo[buf].buftype == type
    end, bufs)
end

return M
