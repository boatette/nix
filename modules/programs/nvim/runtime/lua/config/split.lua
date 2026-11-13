local M = {}

-- moves the split on the arrow's side of the window that way, or the opposite one at the screen edge
function M.move(dir)
    local vertical = dir == "h" or dir == "l"
    local back = vertical and "h" or "k"
    local cur = vim.fn.winnr()
    local before, after = vim.fn.winnr(back), vim.fn.winnr(vertical and "l" or "j")

    -- a separator/statusline belongs to the window left of/above it
    local owner
    if dir == back then
        owner = before ~= cur and before or cur
    else
        owner = after == cur and before or cur
    end
    if owner == cur and after == cur then
        return
    end

    local offset = (dir == back and -2 or 2) * vim.v.count1
    if vertical then
        vim.fn.win_move_separator(owner, offset)
    else
        vim.fn.win_move_statusline(owner, offset)
    end
end

return M
