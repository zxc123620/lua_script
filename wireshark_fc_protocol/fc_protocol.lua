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
-- 功能码
light_function_code = 0x0301
light_function_code_value = "控制信号灯"
function_code_map = {
    [0x00ff] = "心跳",
    [0x0101] = "读取版本",
    [0x0102] = "读取布撤防",
    [0x0201] = "读取网络参数",
    [0x0202] = "修改网络参数",
    [0x0203] = "读取设备参数",
    [0x0204] = "修改设备参数",
    [0x0205] = "读取设备时间",
    [0x0206] = "矫正设备时间",
    [0x0207] = "恢复出厂设置",
    [0x0208] = "QT重命名",
    [light_function_code] = light_function_code_value,
    [0x0302] = "控制喇叭",
    [0x0303] = "控制450M列调",
    [0x0304] = "控制G网",
    [0x0305] = "控制布撤防",
    [0x030a] = "控制设备重启",
    [0x0501] = "布撤防状态发送",
    [0x0103] = "读取温湿度数据",
    [0x0104] = "读取UPS数据",
    [0x0105] = "读取PDU数据",
    [0x0106] = "读取雨量计数据",
    [0x0107] = "读取雨量时间",
    [0x0108] = "读取空调数据",
    [0x0109] = "读取开关门状态",
    [0x0306] = "控制风扇启停",
    [0x0307] = "雨量计校时",
    [0x0308] = "雨量计清零",
    [0x0309] = "控制PDU继电器",
    [0x030A] = "控制重启"
}
function_code = ProtoField.uint16("fcprotocol.function_code", "Function Code", base.HEX, function_code_map)
-- 时间
-- current_time  = ProtoField.none("fcprotocol.time", "current_time"), -- 时间
-- 长度
data_length = ProtoField.uint16("fcprotocol.data_length", "Data Length", base.DEC) --长度

-- 信号灯控制

light_control = ProtoField.none("fcprotocol.light_control", "Light Control")
light_id = ProtoField.uint8("fcprotocol.light_id", "Light Id", base.HEX)
light_control_cmd = ProtoField.uint8("fcprotocol.light_control_cmd", "Light Control Cmd", base.HEX, {
    [0x01] = "开启信号灯",
    [0x00] = "关闭信号灯"
})
-- 喇叭控制协议解析数据
-- 喇叭控制父显示
speaker_proto = ProtoField.none("fcprotocol.speaker_control", "Speaker Control")
-- 喇叭ID
speaker_id = ProtoField.uint8("fcprotocol.speaker_id", "Speaker Id", base.HEX)
-- 喇叭语音类型
speaker_voice_type = ProtoField.uint8("fcprotocol.speaker_voice_type", "Speaker Voice Type", base.HEX)
-- 喇叭颜色
speaker_color = ProtoField.uint8("fcprotocol.speaker_color", "Speaker Color", base.HEX, {
    [0x01] = "红色",
    [0x02] = "黄色",
    [0x03] = "绿色"
})
-- 喇叭控制指令
speaker_cmd = ProtoField.uint8("fcprotocol.speaker_cmd", "Speaker Commd", base.HEX, {
    [0x00] = "关闭喇叭",
    [0x01] = "开启喇叭",
})

speaker_voice_cmd = ProtoField.uint8("fcprotocol.speaker_voice_cmd", "Speaker Voice Cmd", base.HEX, {
    [0x00] = "打开声音",
    [0x01] = "关闭声音",
})

speaker_playback_mode = ProtoField.uint8("fcprotocol.speaker_playback_mode", "Speaker PlayBack Mode", base.HEX, {
    [0x01] = "单曲播放",
    [0x02] = "循环播放",
})

-- 定义协议字段（字段标识符、显示名称、数据格式）
fc_proto.fields = { header, device_id, function_code, data_length, speaker_proto, speaker_id, speaker_voice_type, speaker_color, speaker_cmd, speaker_voice_cmd, speaker_playback_mode, light_control, light_id, light_control_cmd }

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
    subtree:add_le(data_length, buffer(12, 2))      -- 长度

    -- 制作info列的信息
    local function_code_hex = buffer(4, 2):le_uint()
    local header_value_data = buffer(0, 2):uint()
    local data_length_data = buffer(12, 2):le_uint()
    local function_code_value = function_code_map[function_code_hex] or ("未知(0x" .. string.format("%04X", function_code_hex) .. ")")
    local header_value = header_str_map[header_value_data] or ("未知(0x" .. string.format("%04X", header_value_data) .. ")")

    -- 解析数据部分
    if function_code_hex == light_function_code then
        if header_value_data == 0xe3e4 then
            local light_tree = subtree:add(light_control, buffer(14, data_length_data))
            light_tree.add(light_id, buffer(0, 1))
            light_tree.add(light_control_cmd, buffer(1, 1))
        end
    end
    -- 设置信息列摘要
    pinfo.cols.info = string.format("数据流向: %s 数据类型: %s", header_value, function_code_value)
end

-- 注册协议到指定端口
local udp_table = DissectorTable.get("tcp.port")
udp_table:add(5001, fc_proto)
