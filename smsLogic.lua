--- 模块功能：短信处理.
-- @author wangliulei
-- @module sms
-- @license MIT
-- @copyright openLuat
-- @release 2023.03.15

module(...,package.seeall)
require"sms"

local function procnewsms(num,data,datetime)
    -- 当收到新短信时，打印短信发送方的手机号、短信内容和时间
    log.info("testSms.procnewsms",num,data,datetime)
    -- 样例：01-小杨-14787654982
    -- 编号-姓名-电话号码
    smsList = string.split(data,"-")
    if table.getn(smsList) ~= 3 then
        log.error("Sms.procnewsms: 格式错误")
        return
    end

    pb.write(smsList[1], smsList[2], smsList[3], writecb)
end

-- 设置新短信来时的处理函数
sms.setNewSmsCb(procnewsms)

--pb.write()接口的回调函数
function writecb(result)
    log.info("Sms.Pb.writecb",result)
end
