--- 模块功能：通话.
-- @author wangliulei
-- @module call
-- @license MIT
-- @copyright openLuat
-- @release 2022.12.25

module(...,package.seeall)
require"cc"
require"audio"
require"common"

--来电铃声播放协程ID
local coIncoming


--- “通话已建立”消息处理函数
-- @string num，建立通话的对方号码
-- @return 无
local function connected(num)
    log.info("testCall.connected", "号码：",num)
    coIncoming = nil
    --通话中设置mic增益，必须在通话建立以后设置
    audio.setMicGain("call",7)
    callNumber = num
    callStatus = CALL
end

--- “通话已结束”消息处理函数
-- @string discReason，通话结束原因值，取值范围如下：
--                                     "CHUP"表示本端调用cc.hungUp()接口主动挂断
--                                     "NO ANSWER"表示呼出后，到达对方，对方无应答，通话超时断开
--                                     "BUSY"表示呼出后，到达对方，对方主动挂断
--                                     "NO CARRIER"表示通话未建立或者其他未知原因的断开
--                                     nil表示没有检测到原因值
-- @return 无
local function disconnected(discReason)
    coIncoming = nil
    callStatus = NOTCALL
    log.info("testCall.disconnected",discReason)
    sys.timerStopAll(cc.hangUp)
    audio.stop()
end

--- “来电”消息处理函数
-- @string num，来电号码
-- @return 无
local function incoming(num)
    log.info("testCall.incoming:"..num)

    if not coIncoming then
        callStatus = RING
        callNumber = num
        coIncoming = sys.taskInit(function()
            while true do
                log.info("test", "响铃声")
                audio.play(2,"FILE","/lua/call.mp3",4,function() sys.publish("PLAY_INCOMING_RING_IND") end,true)
                sys.waitUntil("PLAY_INCOMING_RING_IND")
                break
            end
        end)
        -- sys.subscribe("POWER_KEY_IND",function() log.info("test", "接听") audio.stop(function() cc.accept(num) end) end)
    end
end

--- “通话功能模块准备就绪””消息处理函数
-- @return 无
local function ready()
    log.info("testCall.ready")
    audio.play(1,"TTS","准备就绪",4)
    pb.read(1,readcb)
end

--- “通话中收到对方的DTMF”消息处理函数
-- @string dtmf，收到的DTMF字符
-- @return 无
local function dtmfDetected(dtmf)
    log.info("testCall.dtmfDetected",dtmf)
end

-- 读取电话本
function readcb(result,name,number)
    log.info("test","电话本:",result,name,number)
end


--订阅消息的用户回调函数
audio.play(1,"TTS","启动成功",2)
result = cc.anyCallExist()
log.info("test", "通话查询:", result)
state = cc.getState('10086')
log.info("test", "通话状态:", state)

audio.setChannel(2)
require"pb"
log.info("test", "测试结束")

-- sys.subscribe("CALL_READY",ready)
sys.subscribe("NET_STATE_REGISTERED",ready)
sys.subscribe("CALL_INCOMING",incoming)
sys.subscribe("CALL_CONNECTED",connected)
sys.subscribe("CALL_DISCONNECTED",disconnected)
cc.dtmfDetect(true)
sys.subscribe("CALL_DTMF_DETECT",dtmfDetected)

sys.subscribe("POWER_KEY_IND_LONG",function()
    log.info("test", "按键！")
    if callStatus == 0 then
        cc.dial(14780136998)
    end
end)

sys.subscribe("POWER_KEY_IND",function()
    if callStatus == NOTCALL then
        log.info("test", "打电话")
        -- num = 14780136998
        cc.dial(14780136998)
        callStatus = CALL
        callNumber = 14780136998
    elseif callStatus == RING then
        log.info("test", "接听")
        audio.stop(function() cc.accept(callNumber) end)
    elseif callStatus == CALL then
        log.info("test", "挂断")
        cc.hangUp(callNumber)
        callNumber = nil
    end
end)


