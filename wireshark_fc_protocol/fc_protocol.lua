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
header = ProtoField.uint16("fcprotocol.header", "Header", base.HEX, header_str_map)
-- 设备ID
device_id = ProtoField.uint16("fcprotocol.device_id", "Device Id", base.HEX)
-- 执行结果
fc_execute_result = ProtoField.uint8("fcprotocol.exec_res", "Execute Result", base.DEC, {
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
    [pdu_control_code_map.code] = pdu_control_code_map.value
}
function_code = ProtoField.uint16("fcprotocol.function_code", "Function Code", base.HEX, function_code_map)
-- 时间
current_time  = ProtoField.none("fcprotocol.time", "Current Time") -- 时间
time_year = ProtoField.uint8("fcprotocol.year", "Year", base.DEC)
time_month = ProtoField.uint8("fcprotocol.month", "Month", base.DEC)
time_day = ProtoField.uint8("fcprotocol.day", "Day", base.DEC)
time_hour = ProtoField.uint8("fcprotocol.hour", "Hour", base.DEC)
time_minute = ProtoField.uint8("fcprotocol.minute", "Minute", base.DEC)
time_second = ProtoField.uint8("fcprotocol.second", "Second", base.DEC)

-- 长度
data_length = ProtoField.uint16("fcprotocol.data_length", "Data Length", base.DEC) --长度

-- 信号灯控制

light_proto = ProtoField.none("fcprotocol.light_proto", "Light Proto")
light_id = ProtoField.uint8("fcprotocol.light_id", "Light Id", base.HEX)
light_control_cmd = ProtoField.uint8("fcprotocol.light_control_cmd", "Light Control Cmd", base.HEX, {
    [0x01] = "开启信号灯",
    [0x00] = "关闭信号灯"
})
-- 喇叭控制协议解析数据
-- 喇叭控制父显示
speaker_proto = ProtoField.none("fcprotocol.speaker_proto", "Speaker Proto")
-- 喇叭ID
speaker_id = ProtoField.uint8("fcprotocol.speaker_id", "Speaker Id", base.HEX)
-- 喇叭语音类型
speaker_voice_type = ProtoField.uint8("fcprotocol.speaker_voice_type", "Speaker Voice Type", base.HEX, {
    [0x01] = "驱赶动物",
    [0x02] = "驱赶行人",
    [0x03] = "其他类型"
})
-- 喇叭颜色
speaker_color = ProtoField.uint8("fcprotocol.speaker_color", "Speaker Color", base.HEX, {
    [0x01] = "红色",
    [0x02] = "黄色",
    [0x03] = "绿色"
})
-- 喇叭控制指令
speaker_color_cmd = ProtoField.uint8("fcprotocol.speaker_color_cmd", "Speaker Color Control", base.HEX, {
    [0x00] = "开启灯光",
    [0x01] = "关闭灯光",
})
-- 音量
speaker_volume = ProtoField.uint8("fcprotocol.speaker_volume", "Speaker Volume", base.DEC)
-- 声音开关
speaker_voice_cmd = ProtoField.uint8("fcprotocol.speaker_voice_cmd", "Speaker Voice Cmd", base.HEX, {
    [0x00] = "打开声音",
    [0x01] = "关闭声音",
})
-- 播放模式
speaker_playback_mode = ProtoField.uint8("fcprotocol.speaker_playback_mode", "Speaker PlayBack Mode", base.HEX, {
    [0x01] = "单曲播放",
    [0x02] = "循环播放",
})

-- 450列调
intercom_proto = ProtoField.none("fcprotocol.intercom_proto", "Intercom Proto")
-- 开关
intercom_cmd = ProtoField.uint8("fcprotocol.intercom_cmd", "Intercom Cmd", base.HEX, {
    [0x00] = "开启450列调",
    [0x01] = "关闭450列调",
})
-- 报警类型
intercom_voice_type = ProtoField.uint8("fcprotocol.intercom_voice_type", "Intercom Voice Type", base.DEC)

-- G网
g_net_proto = ProtoField.none("fcprotocol.g_net_proto", "GNet Proto")
g_net_cmd = ProtoField.uint8("fcprotocol.g_net_cmd", "GNet Cmd", base.HEX, {
    [0x00] = "开启G网列调",
    [0x01] = "关闭G网列调",
})
g_net_call_type = ProtoField.uint8("fcprotocol.g_net_call_type", "GNet Call Type", base.HEX, {
    [0x00] = "点呼",
    [0x01] = "组呼",
})
--g_net_phone_number = ProtoField.bytes("fcprotocol.g_net_phone_number", "GNet Phone Number")
-- 布撤防
defence_cmd = ProtoField.uint8("fcprotocol.defence_cmd", "Defence Cmd", base.HEX, {
    [0x00] = "撤防",
    [0x01] = "布防",
})

-- 传感器ID
sensor_id = ProtoField.uint8("fcprotocol.sensor_id", "Sensor Id", base.HEX)
-- 传感器类型
sensor_type = ProtoField.uint8("fcprotocol.sensor_type", "Sensor Type", base.HEX)
-- 执行状态
sensor_exec_status =  ProtoField.uint8("fcprotocol.sensor_exec_status", "Sensor Exec Type", base.HEX)

-- 温湿度数据
tem_and_hum_proto = ProtoField.none("fcprotocol.tem_and_hum_proto", "Temperature and Humility Proto")
tem_data = ProtoField.uint16("fcprotocol.tem_data", "Temperature Data", base.DEC)
hum_data = ProtoField.uint16("fcprotocol.hum_data", "Humility Data", base.DEC)

-- 雨量数据
rain_proto =  ProtoField.none("fcprotocol.rain_proto", "Rain Data")
today_rain = ProtoField.uint16("fcprotocol.today_rain", "Today Day", base.DEC)
instance_rain = ProtoField.uint16("fcprotocol.instance_rain", "Instance Day", base.DEC)
yesterday_rain = ProtoField.uint16("fcprotocol.yesterday_rain", "Yesterday Day", base.DEC)
total_rain = ProtoField.uint16("fcprotocol.total_rain", "Total Day", base.DEC)
hour_rain = ProtoField.uint16("fcprotocol.hour_rain", "Hour Day", base.DEC)
last_hour_rain = ProtoField.uint16("fcprotocol.last_hour_rain", "Last Hour Day", base.DEC)
max_24_hour_rain = ProtoField.uint16("fcprotocol.max_24_hour_rain", "Max 24 Hour Rain", base.DEC)
min_24_hour_rain = ProtoField.uint16("fcprotocol.min_24_hour_rain", "Min 24 Hour Rain", base.DEC)
max_24_hour_rain_range = ProtoField.uint16("fcprotocol.max_24_hour_rain_range", "Max 24 Hour Rain Range", base.HEX)
min_24_hour_rain_range = ProtoField.uint16("fcprotocol.min_24_hour_rain_range", "Min 24 Hour Rain Range", base.HEX)

-- UPS
ups_proto = ProtoField.none("fcprotocol.ups_proto", "Ups Data")
ups_battery_work_status = ProtoField.uint8("fcprotocol.ups_battery_work_status", "Battery Work Status", base.DEC, {
    [0] = "Good",
    [1] = "Weak",
    [2] = "Replace"
})
-- 电池电量
ups_battery_power_level_status = ProtoField.uint8("fcprotocol.ups_battery_power_level_status", "Battery Power Level Status", base.DEC, {
    [0] = "OK",
    [1] = "Low",
    [2] = "Depleted"
})
-- 充放电状态
ups_battery_charge_status = ProtoField.uint8("fcprotocol.ups_battery_charge_status", "Battery Charge Status", base.DEC, {
    [0] = "Obsolete",
    [1] = "Charging",
    [2] = "Resting",
    [3] = "Discharging"
})
ups_charge_seconds = ProtoField.uint16("fcprotocol.ups_charge_seconds", "Supply Seconds", base.DEC)
ups_remain_minutes = ProtoField.uint16("fcprotocol.ups_remain_minutes", "Remain Minutes", base.DEC)
ups_remain_battery = ProtoField.uint16("fcprotocol.ups_remain_battery", "Remain Battery(%)", base.DEC)
ups_voltage_pre = ProtoField.uint16("fcprotocol.ups_voltage_pre", "Voltage-1", base.DEC)
ups_voltage_post = ProtoField.uint16("fcprotocol.ups_voltage_post", "Voltage-2", base.DEC)
ups_inner_temperature =   ProtoField.uint16("fcprotocol.ups_inner_temperature", "Inner Temperature", base.DEC)
ups_battery =   ProtoField.uint16("fcprotocol.ups_battery", "Battery", base.DEC)

-- crc数据
crc_data_proto = ProtoField.uint16("fcprotocol.crc", "Crc Data", base.HEX)

-- 定义协议字段（字段标识符、显示名称、数据格式）
fc_proto.fields = { ups_battery, ups_inner_temperature, ups_voltage_post, ups_remain_battery, ups_voltage_pre, ups_proto, ups_battery_work_status, ups_battery_power_level_status,ups_battery_charge_status, ups_charge_seconds,ups_remain_minutes,  rain_proto, today_rain,instance_rain,yesterday_rain,total_rain, hour_rain,last_hour_rain, min_24_hour_rain_range, max_24_hour_rain_range, min_24_hour_rain, max_24_hour_rain, tem_data,hum_data,  sensor_id,  sensor_type, tem_and_hum_proto, crc_data_proto, light_proto,light_id, light_control_cmd, current_time, time_year, time_month,time_day,  time_hour, time_minute,time_second,  fc_execute_result, header, device_id, function_code, data_length, speaker_proto, speaker_id, speaker_voice_type, speaker_color, speaker_color_cmd,speaker_volume, speaker_voice_cmd, speaker_playback_mode,intercom_proto,intercom_cmd,intercom_voice_type,g_net_proto ,g_net_cmd ,g_net_call_type,defence_cmd }

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
    local current_time_proto = subtree:add(current_time, buffer(6, 6)) -- 时间父类
    current_time_proto:add(time_year, buffer(6, 1))
    current_time_proto:add(time_month, buffer(7, 1))
    current_time_proto:add(time_day, buffer(8, 1))
    current_time_proto:add(time_hour, buffer(9, 1))
    current_time_proto:add(time_minute, buffer(10, 1))
    current_time_proto:add(time_second, buffer(11, 1))
    subtree:add_le(data_length, buffer(12, 2))      -- 长度

    -- 制作info列的信息
    local function_code_hex = buffer(4, 2):le_uint()
    local header_value_data = buffer(0, 2):uint()
    local data_length_data = buffer(12, 2):le_uint()

    print(data_length_data)
    local function_code_str = function_code_map[function_code_hex] or ("未知(0x" .. string.format("%04X", function_code_hex) .. ")")
    local header_value = header_str_map[header_value_data] or ("未知(0x" .. string.format("%04X", header_value_data) .. ")")
    -- 解析fc数据部分
    if header_value_data == 0x6869 then
        -- 控制结果
        if function_code_hex == light_code_map.code or function_code_hex == speaker_code_map.code or function_code_hex == intercom_code_map.code or  function_code_hex == g_net_code_map.code or function_code_hex == defence_code_map.code or function_code_hex == device_rest_code_map.code or function_code_hex == device_reboot_code_map.code or function_code_hex == device_date_set_code_map.code  or function_code_hex == net_param_set_code_map.code  or function_code_hex == device_param_set_code_map.code then
            subtree:add_le(fc_execute_result, buffer(14, data_length_data))
        -- 布撤防状态发送
        elseif function_code_hex == defence_status_code_map.code then
            subtree:add(defence_cmd, buffer(14, 1))
        -- 温湿度
        elseif function_code_hex == tem_and_hum_code_map.code then
            local tem_and_hum_data = subtree:add(tem_and_hum_proto, buffer(14, data_length_data))
            tem_and_hum_data:add(sensor_id, buffer(14,1))
            tem_and_hum_data:add(sensor_type, buffer(15,1))
            tem_and_hum_data:add(sensor_exec_status, buffer(16,1))
            tem_and_hum_data:add_le(tem_data, buffer(17,2))
            tem_and_hum_data:add_le(hum_data, buffer(19,2))
        -- 雨量数据
        elseif function_code_hex == rain_sensor_code_map.code then
            local rain_data_proto = subtree:add(rain_proto, buffer(14, data_length_data))
            rain_data_proto:add(sensor_id, buffer(14,1))
            rain_data_proto:add(sensor_type, buffer(15,1))
            rain_data_proto:add(sensor_exec_status, buffer(16,1))
            rain_data_proto:add(today_rain, buffer(17,2))
            rain_data_proto:add(instance_rain, buffer(19,2))
            rain_data_proto:add(yesterday_rain, buffer(21,2))
            rain_data_proto:add(total_rain, buffer(23,2))
            rain_data_proto:add(hour_rain, buffer(25,2))
            rain_data_proto:add(last_hour_rain, buffer(27,2))
            rain_data_proto:add(max_24_hour_rain, buffer(29,2))
            rain_data_proto:add(max_24_hour_rain_range, buffer(31,2))
            rain_data_proto:add(min_24_hour_rain, buffer(33,2))
            rain_data_proto:add(min_24_hour_rain_range, buffer(35,2))
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
            local phone_number =  ByteArray.new(phone_number_range:raw(), true):tohex(false)
            g_net_tree:add(phone_number_range, "Phone Number (".. phone_number_range:len() .. "Bytes): " .. phone_number)
        -- 布撤防
        elseif function_code_hex == defence_code_map.code  then
            subtree:add(defence_cmd, buffer(14, 1))
        -- 温湿度 雨量计
        elseif function_code_hex == tem_and_hum_code_map.code or function_code_hex == rain_sensor_code_map.code or function_code_hex == ups_sensor_code_map.code or function_code_hex == pdu_sensor_code_map.code or function_code_hex == aircondition_code_map.code  then
            subtree:add(sensor_id, buffer(14,1))
            subtree:add(sensor_type, buffer(15,1))
        end
    end
    subtree:add_le(crc_data_proto, buffer(14+data_length_data, 2))
    -- 设置信息列摘要
    pinfo.cols.info = string.format("数据流向: %s 数据类型: %s", header_value, function_code_str)
end

-- 注册协议到指定端口
local udp_table = DissectorTable.get("tcp.port")
udp_table:add(5001, fc_proto)
