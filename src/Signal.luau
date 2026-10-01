--!strict
local Signal = {}
Signal.__index = Signal

export type SignalHandler = (...any) -> ()
export type SignalConnection = {
    Disconnect: (self: SignalConnection) -> (),
}

function Signal.new()
    return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(fn: SignalHandler): SignalConnection
    table.insert(self._handlers, fn)
    return {
        Disconnect = function()
            local index = table.find(self._handlers, fn)
            if index then
                table.remove(self._handlers, index)
            end
        end,
    }
end

function Signal:Fire(...: any)
    for _, handler in ipairs(self._handlers) do
        task.spawn(handler, ...)
    end
end

return Signal