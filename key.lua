
module(...,package.seeall)

local keyName = {
    [0] = {
        [0] = "USER1",
        [1] = "USER2",
        [2] = "USER3",
        [3] = "USER4"
    },
    [1] = {
        [0] = "SOS",
        [1] = "EXIT"
    },
    [255] = {
        [255] = ""
    }
}

-- 按键消息处理函数
-- @table msg，按键消息体
--               msg.key_matrix_row：number类型，行信息
--               msg.key_matrix_col：number类型，列信息
--               msg.pressed：bool类型，true表示按下，false表示弹起
local function keyMsg(msg)
    log.info(
        "keyMsg",
        msg.key_matrix_row,
        msg.key_matrix_col,
        keyName[msg.key_matrix_row][msg.key_matrix_col],
        msg.pressed
    )

    if keyName[msg.key_matrix_row][msg.key_matrix_col] == "USER1" then
        sys.publish("KEY_USER1", msg.pressed)
    elseif keyName[msg.key_matrix_row][msg.key_matrix_col] == "USER2" then
        sys.publish("KEY_USER2", msg.pressed)
    elseif keyName[msg.key_matrix_row][msg.key_matrix_col] == "USER3" then
        sys.publish("KEY_USER3", msg.pressed)
    elseif keyName[msg.key_matrix_row][msg.key_matrix_col] == "USER4" then
        sys.publish("KEY_USER4", msg.pressed)
    elseif keyName[msg.key_matrix_row][msg.key_matrix_col] == "SOS" then
        sys.publish("KEY_SOS", msg.pressed)
    elseif keyName[msg.key_matrix_row][msg.key_matrix_col] == "EXIT" then
        sys.publish("KEY_EXIT", msg.pressed)
    end
end

--注册按键消息的处理函数
rtos.on(rtos.MSG_KEYPAD, keyMsg)
--初始化键盘阵列
rtos.init_module(rtos.MOD_KEYPAD, 0, 0x1F, 0x1F)

-- 逻辑
sys.subscribe("KEY_USER1", call(1))
sys.subscribe("KEY_USER2", call(2))
sys.subscribe("KEY_USER3", call(3))
sys.subscribe("KEY_USER4", call(4))
sys.subscribe("KEY_SOS", sos())
sys.subscribe("KEY_EXIT", sos())

-- 读取电话本，拨打电话
local function call(id)
    pb.read(id,function(result,name,number)
        log.info("test","电话本:",result,name,number)
        -- 判空？
        cc.dial(number)
        call.callStatus = CALL
        call.callNumber = number
    end)
end

-- S0S
local function sos()
    sosStatus = RUN
    for i=1,4 do
        if sosStatus == RUN then
            log.info("test", "sos", "拨打联系人：", i)
            call(i)
        end
    end
end

--关机键长按关机
