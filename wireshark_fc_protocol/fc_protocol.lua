local bit = require("bit")   -- 已自带，直接 require
-- 定义协议（协议标识符和显示名称）
fc_proto = Proto("fcprotocol", "XLZA_FC_PROTOCOL")

-- 共用数据
-- 头部
header_str_map = {
    [0xe3e4] = "QT->FC",
    [0xe1e2] = "QT->FC",
    [0x6162] = "FC->QT",
    [0x6869] = "FC->QT",
}
header = ProtoField.uint16("fcprotocol.header", "头部字段", base.HEX, header_str_map)
-- 设备ID
device_id = ProtoField.uint16("fcprotocol.device_id", "设备编号", base.HEX)
-- 执行结果
fc_execute_result = ProtoField.uint8("fcprotocol.exec_res", "执行结果", base.DEC, {
    [1] = "成功",
    [2] = "设备未使能",
	[3] = "设备未使能",
	[4] = "其他设备打开,不执行关闭操作",
	[5] = "主QT",
	[6] = "从QT",
	[7] = "RM8000_NoCarrier",
	[8] = "RM8000_Busy",
	[9] = "RM8000_NoAnswer",
	[10] = "RM8000_On_Pho",
	[11] = "RM8000_Off_pho",
	[12] = "其他QT打开了信号灯",
	[255] = "MODBUS_ERR_NOT_MASTER",
	[254] = "MODBUS_ERR_POLLING",
	[253] = "MODBUS_ERR_BUFF_OVERFLOW",
	[252] = "MODBUS_ERR_BAD_CRC",
	[251] = "MODBUS_ERR_EXCEPTION",
	[250] = "MODBUS_ERR_BAD_SIZE",
	[249] = "MODBUS_ERR_BAD_ADDRESS",
	[248] = "MODBUS_ERR_TIME_OUT",
	[247] = "MODBUS_ERR_BAD_SLAVE_ID",
	[246] = "MODBUS_ERR_BAD_TCP_ID",
	[245] = "MODBUS_ERR_OK_QUERY",
	[244] = "RM8000_PHO_Err",
	[243] = "RM8000_Error",
	[242] = "YX9100_INIT",
	[241] = "YX9100_NOT_RECV_CPL",
	[240] = "YX9100_CRC_ERR",
	[239] = "YX9100_FOLDER_OVER_RANGE",
	[238] = "YX9100_FOLDER_NOT_FIND",
	[237] = "YX9100_DATA_ERR",
	[236] = "DEV_NO_RESPONSE",
	[235] = "Alarm_Music_Err",
	[234] = "DEV_TEST_Err",
	[233] = "Alarmled_Num_err",
	[232] = "Alarmled_ACSAMP_err",
	[231] = "M450_Disable",
	[230] = "DEV_FUNC_Err",
	[229] = "RM8000_TimeOut",
	[228] = "RM8000_NO_Signal",
	[227] = "RM8000_Unrecognized_Signal"

})
-- 功能码
heartbeat_code_map = {code = 0x00ff, value = "心跳"}
version_get_code_map = {code = 0x0101, value = "读取版本"}
defence_get_code_map = {code = 0x0102, value = "读取布撤防"}
net_param_get_code_map = {code = 0x0201, value = "读取网络参数"}
net_param_set_code_map = {code = 0x0202, value = "修改网络参数"}
device_param_get_code_map = {code = 0x0203, value = "读取设备参数"}
device_param_set_code_map = {code = 0x0204, value = "修改设备参数"}
device_date_get_code_map = {code = 0x0205, value = "读取设备时间"}
device_date_set_code_map = {code = 0x0206, value = "矫正设备时间"}
device_rest_code_map = {code = 0x0207, value = "恢复出厂设置"}
rename_code_map = {code = 0x0208, value = "重命名"}
light_code_map = {code = 0x0301, value = "控制信号灯"} -- 信号灯
speaker_code_map = {code = 0x0302, value = "控制喇叭"} -- 喇叭
intercom_code_map = {code = 0x0303, value = "控制450M列调"} -- 450
g_net_code_map = {code = 0x0304, value = "控制G网"}  --G网
defence_code_map = {code = 0x0305, value = "控制布撤防"} --布撤防
device_reboot_code_map = {code = 0x030a,value = "控制设备重启" }
defence_status_code_map = {code = 0x0501, value = "布撤防状态发送"}
tem_and_hum_code_map = {code = 0x0103, value = "读取温湿度数据"}
ups_sensor_code_map = {code = 0x0104, value = "读取UPS数据"}
pdu_sensor_code_map = {code = 0x0105, value = "读取PDU数据"}
rain_sensor_code_map = {code = 0x0106, value = "读取雨量计数据"}
rain_date_code_map = {code = 0x0107, value = "读取雨量时间"}
aircondition_code_map = {code = 0x0108, value = "读取空调数据"}
door_sensor_code_map = {code = 0x0109, value = "读取开关门状态"}
fan_sensor_code_map = {code = 0x0306, value = "控制风扇启停"}
rain_calib_code_map = {code = 0x0307, value = "雨量计校时"}
rain_clear_code_map = {code = 0x0308, value = "雨量计清零"}
pdu_control_code_map = {code = 0x0309, value = "控制PDU继电器"}
door_send_map = {code = 0x0505, value = "门控状态"}
request_rtc_map = {code = 0x0502, value = "RTC校时"}

function_code_map = {
    [heartbeat_code_map.code] = heartbeat_code_map.value,
    [version_get_code_map.code] = version_get_code_map.value,
    [defence_get_code_map.code] = defence_get_code_map.value,
    [net_param_get_code_map.code] = net_param_get_code_map.value,
    [net_param_set_code_map.code] = net_param_set_code_map.value,
    [device_param_get_code_map.code] = device_param_get_code_map.value,
    [device_param_set_code_map.code] = device_param_set_code_map.value,
    [device_date_get_code_map.code] = device_date_get_code_map.value,
    [device_date_set_code_map.code] = device_date_set_code_map.value,
    [device_rest_code_map.code] = device_rest_code_map.value,
    [rename_code_map.code] = rename_code_map.value,
    [light_code_map.code] = light_code_map.value,
    [speaker_code_map.code] = speaker_code_map.value,
    [intercom_code_map.code] = intercom_code_map.value,
    [g_net_code_map.code] = g_net_code_map.value,
    [defence_code_map.code] = defence_code_map.value,
    [device_reboot_code_map.code] = device_reboot_code_map.value,
    [defence_status_code_map.code] = defence_status_code_map.value,
    [tem_and_hum_code_map.code] = tem_and_hum_code_map.value,
    [ups_sensor_code_map.code] = ups_sensor_code_map.value,
    [pdu_sensor_code_map.code] = pdu_sensor_code_map.value,
    [rain_sensor_code_map.code] = rain_sensor_code_map.value,
    [rain_date_code_map.code] = rain_date_code_map.value,
    [aircondition_code_map.code] = aircondition_code_map.value,
    [door_sensor_code_map.code] = door_sensor_code_map.value,
    [fan_sensor_code_map.code] = fan_sensor_code_map.value,
    [rain_calib_code_map.code] = rain_calib_code_map.value,
    [rain_clear_code_map.code] = rain_clear_code_map.value,
    [pdu_control_code_map.code] = pdu_control_code_map.value,
    [door_send_map.code] = door_send_map.value,
    [request_rtc_map.code] = request_rtc_map.value
}
function_code = ProtoField.uint16("fcprotocol.function_code", "功能码", base.HEX, function_code_map)
-- 时间
current_time  = ProtoField.none("fcprotocol.time", "当前时间") -- 时间
time_year = ProtoField.uint8("fcprotocol.year", "年", base.DEC)
time_month = ProtoField.uint8("fcprotocol.month", "月", base.DEC)
time_day = ProtoField.uint8("fcprotocol.day", "日", base.DEC)
time_hour = ProtoField.uint8("fcprotocol.hour", "时", base.DEC)
time_minute = ProtoField.uint8("fcprotocol.minute", "分", base.DEC)
time_second = ProtoField.uint8("fcprotocol.second", "秒", base.DEC)

-- 长度
data_length = ProtoField.uint16("fcprotocol.data_length", "数据长度", base.DEC) --长度

-- 信号灯控制

light_proto = ProtoField.none("fcprotocol.light_proto", "信号灯控制协议")
light_id = ProtoField.uint8("fcprotocol.light_id", "信号灯编号", base.HEX)
light_control_cmd = ProtoField.uint8("fcprotocol.light_control_cmd", "控制指令", base.HEX, {
    [0x01] = "开启信号灯",
    [0x00] = "关闭信号灯"
})
-- 喇叭控制协议解析数据
-- 喇叭控制父显示
speaker_proto = ProtoField.none("fcprotocol.speaker_proto", "喇叭控制协议")
-- 喇叭ID
speaker_id = ProtoField.uint8("fcprotocol.speaker_id", "喇叭编号", base.HEX)
-- 喇叭语音类型
speaker_voice_type = ProtoField.uint8("fcprotocol.speaker_voice_type", "语音类型", base.HEX, {
    [0x01] = "驱赶动物",
    [0x02] = "驱赶行人",
    [0x03] = "其他类型"
})
-- 喇叭颜色
speaker_color = ProtoField.uint8("fcprotocol.speaker_color", "灯光选择", base.HEX, {
    [0x01] = "红色",
    [0x02] = "黄色",
    [0x03] = "绿色"
})
-- 喇叭控制指令
speaker_color_cmd = ProtoField.uint8("fcprotocol.speaker_color_cmd", "灯光指令", base.HEX, {
    [0x01] = "开启灯光",
    [0x00] = "关闭灯光"
})
-- 音量
speaker_volume = ProtoField.uint8("fcprotocol.speaker_volume", "喇叭音量", base.DEC)
-- 声音开关
speaker_voice_cmd = ProtoField.uint8("fcprotocol.speaker_voice_cmd", "声音指令", base.HEX, {
    [0x01] = "打开声音",
    [0x00] = "关闭声音"
})
-- 播放模式
speaker_playback_mode = ProtoField.uint8("fcprotocol.speaker_playback_mode", "播放模式", base.HEX, {
    [0x01] = "单曲播放",
    [0x02] = "循环播放"
})

-- 450列调
intercom_proto = ProtoField.none("fcprotocol.intercom_proto", "列调控制协议")
-- 开关
intercom_cmd = ProtoField.uint8("fcprotocol.intercom_cmd", "控制指令", base.HEX, {
    [0x01] = "开启450列调",
    [0x00] = "关闭450列调"
})
-- 报警类型
intercom_voice_type = ProtoField.uint8("fcprotocol.intercom_voice_type", "报警类别", base.DEC)

-- G网
g_net_proto = ProtoField.none("fcprotocol.g_net_proto", "G网控制协议")
g_net_cmd = ProtoField.uint8("fcprotocol.g_net_cmd", "控制指令", base.HEX, {
    [0x01] = "开启G网列调",
    [0x00] = "关闭G网列调"
})
g_net_call_type = ProtoField.uint8("fcprotocol.g_net_call_type", "呼叫方式", base.HEX, {
    [0x00] = "点呼",
    [0x01] = "组呼",
})
--g_net_phone_number = ProtoField.bytes("fcprotocol.g_net_phone_number", "GNet Phone Number")
-- 布撤防
defence_cmd = ProtoField.uint8("fcprotocol.defence_cmd", "布撤防指令", base.HEX, {
    [0x00] = "撤防",
    [0x01] = "布防"
})

-- 传感器ID
sensor_id = ProtoField.uint8("fcprotocol.sensor_id", "传感器编号", base.DEC)
-- 传感器类型
sensor_type = ProtoField.uint8("fcprotocol.sensor_type", "传感器类型", base.HEX)
-- 执行状态
sensor_exec_status =  ProtoField.uint8("fcprotocol.sensor_exec_status", "传感器执行状态", base.HEX)

-- 温湿度数据
tem_and_hum_proto = ProtoField.none("fcprotocol.tem_and_hum_proto", "温湿度数据协议")
tem_data = ProtoField.uint16("fcprotocol.tem_data", "温度数据(X10)", base.DEC)
hum_data = ProtoField.uint16("fcprotocol.hum_data", "湿度数据(X10)", base.DEC)

-- 雨量数据
rain_proto =  ProtoField.none("fcprotocol.rain_proto", "雨量数据协议")
today_rain = ProtoField.uint16("fcprotocol.today_rain", "当日雨量(X10)", base.DEC)
instance_rain = ProtoField.uint16("fcprotocol.instance_rain", "瞬时雨量(X10)", base.DEC)
yesterday_rain = ProtoField.uint16("fcprotocol.yesterday_rain", "昨日雨量(X10)", base.DEC)
total_rain = ProtoField.uint16("fcprotocol.total_rain", "总降雨量(X10)", base.DEC)
hour_rain = ProtoField.uint16("fcprotocol.hour_rain", "小时雨量(X10)", base.DEC)
last_hour_rain = ProtoField.uint16("fcprotocol.last_hour_rain", "上小时雨量(X10)", base.DEC)
max_24_hour_rain = ProtoField.uint16("fcprotocol.max_24_hour_rain", "24小时最大雨量(X10)", base.DEC)
min_24_hour_rain = ProtoField.uint16("fcprotocol.min_24_hour_rain", "24小时最小雨量(X10)", base.DEC)
max_24_hour_rain_range = ProtoField.uint16("fcprotocol.max_24_hour_rain_range", "24小时最大降雨时间段", base.HEX)
min_24_hour_rain_range = ProtoField.uint16("fcprotocol.min_24_hour_rain_range", "24小时最小降雨时间段", base.HEX)

-- UPS
ups_proto = ProtoField.none("fcprotocol.ups_proto", "UPS数据协议")
ups_battery_work_status = ProtoField.uint8("fcprotocol.ups_battery_work_status", "电池工作状态", base.DEC, {
    [0] = "Good",
    [1] = "Weak",
    [2] = "Replace"
})
-- 电池电量
ups_battery_power_level_status = ProtoField.uint8("fcprotocol.ups_battery_power_level_status", "电池电量状态", base.DEC, {
    [0] = "OK",
    [1] = "Low",
    [2] = "Depleted"
})
-- 充放电状态
ups_battery_charge_status = ProtoField.uint8("fcprotocol.ups_battery_charge_status", "电池充放电状态", base.DEC, {
    [0] = "Obsolete",
    [1] = "Charging",
    [2] = "Resting",
    [3] = "Discharging"
})
ups_charge_seconds = ProtoField.uint16("fcprotocol.ups_charge_seconds", "电池供电时间(秒)", base.DEC)
ups_remain_minutes = ProtoField.uint16("fcprotocol.ups_remain_minutes", "电池剩余时间(分)", base.DEC)
ups_remain_battery = ProtoField.uint16("fcprotocol.ups_remain_battery", "电池剩余电量(%)", base.DEC)
ups_voltage_pre = ProtoField.uint16("fcprotocol.ups_voltage_pre", "电池电压(整数位)", base.DEC)
ups_voltage_post = ProtoField.uint16("fcprotocol.ups_voltage_post", "电池电压(小数位)", base.DEC)
ups_inner_temperature =   ProtoField.uint16("fcprotocol.ups_inner_temperature", "电池内部温度", base.DEC)
ups_battery =   ProtoField.uint16("fcprotocol.ups_battery", "电池电量", base.DEC)

-- PDU数据
pdu_proto = ProtoField.none("fcprotocol.pdu_proto", "PDU 数据")
bit_value =ProtoField.bool("fcprotocol.bit_status", "Bit Status")

-- 风扇控制
fan_proto = ProtoField.none("fcprotocol.fan_proto", "风扇控制及协议")
--senser_number = ProtoField.uint8("fcprotocol.number", "传感器设备编号", base.DEC)
fan_cmd = ProtoField.uint8("fcprotocol.fan_cmd", "风扇指令", base.DEC, {
    [0] = "关闭风扇",
    [1] = "开启风扇"
})

-- 继电器控制
reply_proto = ProtoField.none("fcprotocol.reply_proto", "PDU控制协议")
relay_cmd = ProtoField.uint8("fcprotocol.relay_cmd", "控制指令", base.DEC, {
    [0] = "关闭继电器",
    [1] = "开启继电器"
})
relay_number = ProtoField.uint8("fcprotocol.relay_number", "继电器编号", base.DEC)
-- 门控状态
door_proto = ProtoField.none("fcprotocol.door_proto", "门控状态")

device_mode = ProtoField.uint8("fcprotocol.device_mode", "主/从模式", base.DEC, {
    [1] = "主模式",
    [2] = "从模式"
})
-- crc数据
crc_data_proto = ProtoField.uint16("fcprotocol.crc", "Crc 校验", base.HEX)

net_param_proto = ProtoField.none("fcprotocol.net_proto", "网络参数")

-- 定义协议字段（字段标识符、显示名称、数据格式）
fc_proto.fields = {device_mode, net_param_proto,door_proto,relay_number,
    reply_proto,relay_cmd, fan_proto, fan_cmd, pdu_proto, bit_value, ups_battery, ups_inner_temperature,
    ups_voltage_post, ups_remain_battery, ups_voltage_pre, ups_proto, ups_battery_work_status, ups_battery_power_level_status,ups_battery_charge_status,
    ups_charge_seconds,ups_remain_minutes,  rain_proto, today_rain,instance_rain,yesterday_rain,total_rain, hour_rain,last_hour_rain, min_24_hour_rain_range,
    max_24_hour_rain_range, min_24_hour_rain, max_24_hour_rain, tem_data,hum_data,  sensor_id,  sensor_type, tem_and_hum_proto, crc_data_proto, light_proto,
    light_id, light_control_cmd, current_time, time_year, time_month,time_day,  time_hour, time_minute,time_second,  fc_execute_result,
    header, device_id, function_code, data_length, speaker_proto, speaker_id, speaker_voice_type, speaker_color, speaker_color_cmd,speaker_volume,
    speaker_voice_cmd, speaker_playback_mode,intercom_proto,intercom_cmd,intercom_voice_type,g_net_proto ,g_net_cmd ,g_net_call_type,defence_cmd,sensor_exec_status
}

function net_param_parser(subtree, buffer,data_length_data)
    local net_param_proto = subtree:add(net_param_proto, buffer(14,data_length_data))
    net_param_proto:add( buffer(14,4), string.format("设备IP地址: %s.%s.%s.%s", buffer(14,1):uint(), buffer(15,1):uint(),buffer(16,1):uint(),buffer(17,1):uint()))
    net_param_proto:add( buffer(18,2), string.format("监听端口: %s", buffer(18,2):le_uint()))
    net_param_proto:add( buffer(20,4), string.format("设备网关: %s.%s.%s.%s", buffer(20,1):uint(), buffer(21,1):uint(),buffer(22,1):uint(),buffer(23,1):uint()))
    net_param_proto:add( buffer(24,4), string.format("子网掩码: %s.%s.%s.%s", buffer(24,1):uint(), buffer(25,1):uint(),buffer(26,1):uint(),buffer(27,1):uint()))
    net_param_proto:add( buffer(28,6), string.format("MAC地址: %s.%s.%s.%s.%s.%s",
    string.format("%X", buffer(28,1):uint()),
    string.format("%X", buffer(29,1):uint()),
    string.format("%X", buffer(30,1):uint()),
    string.format("%X", buffer(31,1):uint()),
    string.format("%X", buffer(32,1):uint()),
    string.format("%X", buffer(33,1):uint())))
    net_param_proto:add( buffer(34,4), string.format("主DNS: %s.%s.%s.%s", buffer(34,1):uint(), buffer(35,1):uint(),buffer(36,1):uint(),buffer(37,1):uint()))
    net_param_proto:add( buffer(38,4), string.format("备DNS: %s.%s.%s.%s", buffer(38,1):uint(), buffer(39,1):uint(),buffer(40,1):uint(),buffer(41,1):uint()))
    net_param_proto:add( buffer(42,2), string.format("心跳间隔: %s", buffer(42,2):le_uint()))
end
-- 核心解析函数
function fc_proto.dissector(buffer, pinfo, tree)
    -- 检查数据包长度是否足够
    if buffer:len() < 16 then
        return
    end

    -- 设置协议列显示名称
    pinfo.cols.protocol = fc_proto.name

    -- 创建协议子树
    local subtree = tree:add(fc_proto, buffer(), "FC Protocol Data")

    -- 解析字段并添加到树
    subtree:add(header, buffer(0, 2))      -- 头部
    subtree:add_le(device_id, buffer(2, 2))      -- 设备ID
    subtree:add_le(function_code, buffer(4, 2))      -- 功能码
    subtree:add(buffer(6, 6), string.format("当前时间: %s年%s月%s日 %s时%s分%s秒", buffer(6, 1):uint(), buffer(7, 1):uint(),buffer(8, 1):uint(),buffer(9, 1):uint(),buffer(10, 1):uint(),buffer(11, 1):uint()))
    --local current_time_proto = subtree:add(current_time, buffer(6, 6)) -- 时间父类
    --current_time_proto:add(time_year, buffer(6, 1))
    --current_time_proto:add(time_month, buffer(7, 1))
    --current_time_proto:add(time_day, buffer(8, 1))
    --current_time_proto:add(time_hour, buffer(9, 1))
    --current_time_proto:add(time_minute, buffer(10, 1))
    --current_time_proto:add(time_second, buffer(11, 1))
    subtree:add_le(data_length, buffer(12, 2))      -- 长度

    -- 制作info列的信息
    local function_code_hex = buffer(4, 2):le_uint()
    local header_value_data = buffer(0, 2):uint()
    local data_length_data = buffer(12, 2):le_uint()

    print(data_length_data)
    local function_code_str = function_code_map[function_code_hex] or ("未知(0x" .. string.format("%04X", function_code_hex) .. ")")
    local header_value = header_str_map[header_value_data] or ("未知(0x" .. string.format("%04X", header_value_data) .. ")")
    -- 解析fc 控制数据部分
    if header_value_data == 0x6869 then
        -- 控制结果
        if function_code_hex == light_code_map.code or function_code_hex == speaker_code_map.code
            or function_code_hex == intercom_code_map.code or  function_code_hex == g_net_code_map.code
            or function_code_hex == defence_code_map.code or function_code_hex == device_rest_code_map.code
            or function_code_hex == device_reboot_code_map.code or function_code_hex == device_date_set_code_map.code
            or function_code_hex == net_param_set_code_map.code  or function_code_hex == device_param_set_code_map.code then
            subtree:add_le(fc_execute_result, buffer(14, data_length_data))
        -- 布撤防状态发送
        elseif function_code_hex == defence_status_code_map.code or function_code_hex == defence_get_code_map.code then
            subtree:add(defence_cmd, buffer(14, 1))
        -- 网络参数设置
        elseif function_code_hex == net_param_get_code_map.code then
            net_param_parser(subtree, buffer,data_length_data )
        end
    -- 采集
    elseif header_value_data == 0x6162 then
        -- 雨量数据
        if function_code_hex == rain_sensor_code_map.code then
            local rain_data_proto = subtree:add(rain_proto, buffer(14, data_length_data))
            rain_data_proto:add(sensor_id, buffer(14,1))
            rain_data_proto:add(sensor_type, buffer(15,1))
            --rain_data_proto:add(sensor_exec_status, buffer(16,1))
            rain_data_proto:add(fc_execute_result, buffer(16,1))
            local exec_result =  buffer(16,1):uint()
            if (exec_result == 1) then
                rain_data_proto:add_le(today_rain, buffer(17,2))
                rain_data_proto:add_le(instance_rain, buffer(19,2))
                rain_data_proto:add_le(yesterday_rain, buffer(21,2))
                rain_data_proto:add_le(total_rain, buffer(23,2))
                rain_data_proto:add_le(hour_rain, buffer(25,2))
                rain_data_proto:add_le(last_hour_rain, buffer(27,2))
                rain_data_proto:add_le(max_24_hour_rain, buffer(29,2))
                rain_data_proto:add_le(max_24_hour_rain_range, buffer(31,2))
                rain_data_proto:add_le(min_24_hour_rain, buffer(33,2))
                rain_data_proto:add_le(min_24_hour_rain_range, buffer(35,2))
            end
        -- 温湿度
        elseif function_code_hex == tem_and_hum_code_map.code then
            local tem_and_hum_data = subtree:add(tem_and_hum_proto, buffer(14, data_length_data))
            tem_and_hum_data:add(sensor_id, buffer(14,1))
            tem_and_hum_data:add(sensor_type, buffer(15,1))
            tem_and_hum_data:add(fc_execute_result, buffer(16,1))
            --tem_and_hum_data:add(sensor_exec_status, buffer(16,1))
            local exec_result =  buffer(16,1):uint()
            if (exec_result == 1) then
                tem_and_hum_data:add_le(tem_data, buffer(17,2))
                tem_and_hum_data:add_le(hum_data, buffer(19,2))
            end
        -- ups 数据
        elseif function_code_hex == ups_sensor_code_map.code then
            local ups_proto = subtree:add(ups_proto, buffer(14, data_length_data))
            ups_proto:add(sensor_id, buffer(14,1))
            ups_proto:add(sensor_type, buffer(15,1))
            --ups_proto:add(sensor_exec_status, buffer(16,1))
            ups_proto:add(fc_execute_result, buffer(16,1))
            local exec_result =  buffer(16,1):uint()
            if (exec_result == 1) then
                ups_proto:add(ups_battery_work_status, buffer(17, 1))
                ups_proto:add(ups_battery_power_level_status, buffer(18, 1))
                ups_proto:add(ups_battery_charge_status, buffer(19, 1))
                ups_proto:add_le(ups_charge_seconds, buffer(20, 2))
                ups_proto:add_le(ups_remain_minutes, buffer(22, 2))
                ups_proto:add_le(ups_remain_battery, buffer(24, 2))
                ups_proto:add_le(ups_voltage_pre, buffer(26, 2))
                ups_proto:add_le(ups_voltage_post, buffer(28, 2))
                ups_proto:add_le(ups_inner_temperature, buffer(30, 2))
                ups_proto:add_le(ups_battery, buffer(32, 2))
            end
        -- PDU数据
        elseif function_code_hex == pdu_sensor_code_map.code then
            local pdu_proto = subtree:add(pdu_proto, buffer(14, data_length_data))
            pdu_proto:add(sensor_id, buffer(14,1))
            pdu_proto:add(sensor_type, buffer(15,1))
            pdu_proto:add(fc_execute_result, buffer(16,1))
            local exec_result =  buffer(16,1):uint()
            if (exec_result == 1) then
                local replay_range =  buffer(17,2)
                local overload_range =  buffer(19,2)
                local flag_byte = replay_range:le_uint()
                local alarm_byte = overload_range:le_uint()
                pdu_proto:add(replay_range, string.format(". . . . . . . %d (1号继电器): %s", bit.band( flag_byte, 0x01)//0x01, bit.band( flag_byte, 0x01) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(replay_range, string.format(". . . . . . %d . (2号继电器): %s", bit.band( flag_byte, 0x02)//0x02, bit.band( flag_byte, 0x02) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(replay_range, string.format(". . . . . %d . . (3号继电器): %s", bit.band( flag_byte, 0x04)//0x04, bit.band( flag_byte, 0x04) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(replay_range, string.format(". . . . %d . . . (4号继电器): %s", bit.band( flag_byte, 0x08)//0x08, bit.band( flag_byte, 0x08) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(replay_range, string.format(". . . %d . . . . (5号继电器): %s", bit.band( flag_byte, 0x10)//0x10, bit.band( flag_byte, 0x10) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(replay_range, string.format(". . %d . . . . . (6号继电器): %s", bit.band( flag_byte, 0x20)//0x20, bit.band( flag_byte, 0x20) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(replay_range, string.format(". %d . . . . . . (7号继电器): %s", bit.band( flag_byte, 0x40)//0x40, bit.band( flag_byte, 0x40) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(replay_range, string.format("%d . . . . . . . (8号继电器): %s", bit.band( flag_byte, 0x80)//0x80, bit.band( flag_byte, 0x80) ~= 0 and "闭合" or "断开"))
                pdu_proto:add(overload_range, string.format(". . . . . . . %d (过压报警): %s",bit.band(alarm_byte, 0x01)//0x01, bit.band( alarm_byte, 0x01) ~= 0 and "报警" or "正常"))
                pdu_proto:add(overload_range, string.format(". . . . . . %d . (欠压报警): %s",bit.band(alarm_byte, 0x02)//0x02, bit.band( alarm_byte, 0x02) ~= 0 and "报警" or "正常"))
                pdu_proto:add(overload_range, string.format(". . . . . %d . . (过流报警): %s",bit.band(alarm_byte, 0x04)//0x04, bit.band( alarm_byte, 0x04) ~= 0 and "报警" or "正常"))
                pdu_proto:add(overload_range, string.format(". . . . %d . . . (过功率报警): %s",bit.band(alarm_byte, 0x08)//0x08, bit.band( alarm_byte, 0x08) ~= 0 and "报警" or "正常"))
            end
        -- 门控状态
        elseif function_code_hex == door_sensor_code_map.code or function_code_hex == door_send_map.code  then
            local door_proto = subtree:add(door_proto, buffer(14, data_length_data))
            local flag_byte = buffer(14,1):uint()
            door_proto:add(buffer(14,1), string.format(". . . . . . . %d (前门): %s", bit.band(flag_byte,0x01)//0x01, bit.band(flag_byte, 0x01) ~= 0 and "关门" or "开门"))
            door_proto:add(buffer(14,1), string.format(". . . . . . %d . (后门): %s", bit.band(flag_byte,0x02)//0x02, bit.band(flag_byte, 0x02) ~= 0 and "关门" or "开门"))
        -- PDU控制反馈
        elseif function_code_hex == pdu_control_code_map.code then
            subtree:add(sensor_id, buffer(14,1))
            subtree:add(sensor_type, buffer(15,1))
            subtree:add(fc_execute_result, buffer(16,1))
        -- 网络参数
        elseif function_code_hex == net_param_get_code_map.code then
            net_param_parser(subtree, buffer,data_length_data )
        -- 重启反馈
        elseif function_code_hex == device_reboot_code_map.code then
            subtree:add_le(fc_execute_result, buffer(14, data_length_data))
        end
    -- 解析QT数据部分
    elseif header_value_data == 0xe3e4  then
		-- 信号灯
        if  function_code_hex == light_code_map.code then
            local light_tree = subtree:add(light_proto, buffer(14, data_length_data))
            light_tree:add(light_id, buffer(14, 1))
            light_tree:add(light_control_cmd, buffer(15, 1))
        --   喇叭
        elseif function_code_hex == speaker_code_map.code then
            local speaker_tree = subtree:add(speaker_proto, buffer(14, data_length_data))
            speaker_tree:add(speaker_id, buffer(14, 1))
            speaker_tree:add(speaker_voice_type, buffer(15, 1))
            speaker_tree:add(speaker_color, buffer(16, 1))
            speaker_tree:add(speaker_color_cmd, buffer(17, 1))
            speaker_tree:add(speaker_volume, buffer(18, 1))
            speaker_tree:add(speaker_voice_cmd, buffer(19, 1))
            speaker_tree:add(speaker_playback_mode, buffer(20, 1))
        --    列调
        elseif function_code_hex == intercom_code_map.code then
            local intercom_tree = subtree:add(intercom_proto, buffer(14, data_length_data))
            intercom_tree:add(intercom_cmd, buffer(14, 1))
            intercom_tree:add(intercom_voice_type, buffer(15, 1))
        -- G网
        elseif function_code_hex == g_net_code_map.code then
            local g_net_tree = subtree:add(g_net_proto, buffer(14, data_length_data))
            g_net_tree:add(g_net_cmd, buffer(14, 1))
            g_net_tree:add(intercom_voice_type, buffer(15, 1))
            g_net_tree:add(g_net_call_type, buffer(16, 1))
            local phone_number_range = buffer(17,data_length_data-3)
            g_net_tree:add(phone_number_range, "电话号码 (".. phone_number_range:len() .. "Bytes): " ..  phone_number_range:string())
        -- 布撤防
        elseif function_code_hex == defence_code_map.code  then
            subtree:add(defence_cmd, buffer(14, 1))
        -- 网络参数设置
        elseif function_code_hex == net_param_set_code_map.code then
            net_param_parser(subtree, buffer,data_length_data )
        -- 主从模式配置
        elseif function_code_hex == rename_code_map.code then
            subtree:add(device_mode,buffer(14,1))
            subtree:add(buffer(15,data_length_data - 1), "名称:" .. buffer(15,data_length_data - 1):string())
        end
    elseif header_value_data == 0xe1e2 then
        -- 风扇启停
        if function_code_hex == fan_sensor_code_map.code then
            local fan_proto = subtree:add(fan_proto, buffer(14, data_length_data))
            fan_proto:add(sensor_id, buffer(14,1))
            fan_proto:add(sensor_type, buffer(15,1))
            fan_proto:add_le(fan_cmd, buffer(16,2))
        --  PDU控制
        elseif function_code_hex == pdu_control_code_map.code  then
            local replay_proto = subtree:add(reply_proto, buffer(14, data_length_data))
            replay_proto:add(sensor_id, buffer(14,1))
            replay_proto:add(sensor_type, buffer(15,1))
            replay_proto:add(relay_number, buffer(16,1))
            replay_proto:add_le(relay_cmd, buffer(17,1))
        -- 温湿度 雨量计
        elseif function_code_hex == tem_and_hum_code_map.code or function_code_hex == rain_sensor_code_map.code or function_code_hex == ups_sensor_code_map.code or function_code_hex == pdu_sensor_code_map.code or function_code_hex == aircondition_code_map.code  then
            subtree:add(sensor_id, buffer(14,1))
            subtree:add(sensor_type, buffer(15,1))
        -- 网络参数设置
        elseif function_code_hex == net_param_set_code_map.code then
            net_param_parser(subtree, buffer,data_length_data)
        -- 主从模式
        elseif function_code_hex == rename_code_map.code then
            subtree:add(device_mode,buffer(14,1))
            subtree:add(buffer(15,data_length_data - 1), "名称:" .. buffer(15,data_length_data - 1):string())
        end
    end

    subtree:add_le(crc_data_proto, buffer(14+data_length_data, 2))
    -- 设置信息列摘要

    pinfo.cols.info = string.format("数据流向: %s 数据类型: %s", header_value, function_code_str)
end

-- 注册协议到指定端口
local udp_table = DissectorTable.get("tcp.port")
udp_table:add(5001, fc_proto)
