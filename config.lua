module(...)

-- sos状态
local sosStatus = false

-- 待机
local NOTCALL = 0x00
-- 响铃，包含来电和拨打电话
local RING = 0X01
-- 接听，通话中
local CALL = 0x02
-- 通话状态
local callStatus = NOTCALL

-- 通话号码
local callNumber = nil


function sosRun()
    sosStatus = true
end

function sosStop()
    sosStatus = false
end

function getSos()
    return sosStatus
end


function phoneRing(num)
    callNumber = num
    callStatus = RING
end

function phoneCall(num)
    callNumber = num
    callStatus = CALL
end

function phoneNotCall()
    callNumber = nil
    callStatus = NOTCALL
end

function getPhoneRing()
    return callStatus == RING and true or false
end

function getNumber()
    return callNumber
end
