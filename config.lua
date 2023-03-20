module(...)

-- sos状态
RUN = 0x00
STOP = 0X01
sosStatus = STOP

-- 待机
NOTCALL = 0x00
-- 响铃，包含来电和拨打电话
RING = 0X01
-- 接听，通话中
CALL = 0x02
-- 通话状态
callStatus = NOTCALL

-- 通话号码
callNumber = nil
