local bit = require("bit")   -- 已自带，直接 require
-- 定义协议（协议标识符和显示名称）
ofs_proto = Proto("ofs", "震动光纤服务协议")

-- 共用数据
msg_type_map = {
    [0x00] = "用户身份识别请求",
    [0x01] = "用户身份识别相应",
    [0x02] = "心跳请求",
    [0x03] = "心跳响应",
    [0x06] = "设备状态请求",
    [0x07] = "设备状态回复",
    [0x08] = "布撤防控制",
    [0x09] = "布撤防回复",
    [0x10] = "日志上报",
    [0x11] = "日志上报回复"
}
defence_status_map = {
    [0] = "撤防",
    [1] = "布防"
}
device_status_map = {
    [0] = "离线",
    [1] = "在线"
}
sensor_status_map = {
    [1] = "正常",
    [2] = "异常"
}
-- 起始位
magic = ProtoField.uint16("ofs.magic", "起始位", base.HEX)
-- 版本号
version = ProtoField.uint16("ofs.version", "版本号", base.HEX)
-- 序列号
seq_id = ProtoField.uint16("ofs.seq_id", "序列号", base.DEC)
-- 消息类型
msg_type = ProtoField.uint16("ofs.msg_type", "消息类型", base.HEX,msg_type_map)
-- 长度
data_length = ProtoField.int32("ofs.data_length", "数据长度", base.DEC)
 -- 时间戳
timestamp = ProtoField.int64("ofs.time_stamp", "时间戳", base.DEC)
timestamp_format = ProtoField.string("ofs.time_format", "时间戳解析", base.NONE)
--随机数
nonce = ProtoField.string("ofs.nonce", "随机数", base.NONE)
-- 预留
reserved = ProtoField.uint8("ofs.reserved", "预留", base.HEX)
-- 校验码
sm3_checksum = ProtoField.string("ofs.sm3_check", "校验码", base.NONE)
-- 消息体
data_body = ProtoField.string("ofs.body", "消息体", base.NONE)
-- 设备信息
device_info = ProtoField.string("ofs.device_info", "设备信息", base.NONE)

-- 定义协议字段（字段标识符、显示名称、数据格式）
ofs_proto.fields = {magic,version,seq_id,msg_type,data_length,timestamp,timestamp_format,nonce,sm3_checksum,reserved,data_body,device_info}

function parser_auth_send(body_buffer, body_tree, data_length_int)
    -- 解析认证
    local offset = 0
    while offset < data_length_int do
        local tag, new_offset = body_buffer:varint(offset)
        offset = new_offset
        local field_id = bit.rshift(tag, 3)
        local wire_type = bit.band(tag, 7)
        local _string_len, val_new_offset = body_buffer:varint(offset)
        local content = body_buffer(val_new_offset,_string_len):string(ENC_UTF_8)
        if field_id == 1 and wire_type == 2 then
            body_tree:add(string.format("设备编码: %s", content), body_buffer(val_new_offset, _string_len))
        elseif field_id == 2 and wire_type == 2 then
            body_tree:add(string.format("密码: %s", content), body_buffer(val_new_offset, _string_len))
        end
        offset = val_new_offset + _string_len
    end

end

function parser_device_status_send(body_buffer, body_tree, data_length_int)
    -- 解析设备状态
    local offset = 0
    while offset < data_length_int do
        local tag, new_offset = body_buffer:varint(offset)
        offset = new_offset
        local field_id = bit.rshift(tag, 3)
        local wire_type = bit.band(tag, 7)
        local _data, val_new_offset = body_buffer:varint(offset)
        offset = val_new_offset
        if field_id == 1 and wire_type == 2 then
            local content = body_buffer(val_new_offset,_data):string(ENC_UTF_8)
            body_tree:add(string.format("设备编码: %s", content), body_buffer(val_new_offset, _data))
            offset = offset + _data
        elseif field_id == 2 and wire_type == 0 then
            body_tree:add(string.format("布撤防状态: %s", defence_status_map[_data]), body_buffer(new_offset, val_new_offset - new_offset))
        elseif field_id == 3 and wire_type == 0 then
            body_tree:add(string.format("设备状态: %s", device_status_map[_data]), body_buffer(new_offset, val_new_offset - new_offset))
        elseif field_id == 4 and wire_type == 2 then
            local content = body_buffer(val_new_offset,_data):string(ENC_UTF_8)
            body_tree:add(string.format("发送时间: %s", content), body_buffer(val_new_offset, _data))
            offset = offset + _data
        elseif field_id == 5 and wire_type == 2 then
            -- 嵌套数据
            local inner_offset = val_new_offset
            local inner_data_length = val_new_offset + _data -- 总长度
            local device_info_tree = body_tree:add(device_info, body_buffer(inner_offset, _data)) --添加嵌套协议
            while inner_offset < inner_data_length do
                local inner_tag, inner_new_offset = body_buffer:varint(inner_offset)
                --inner_offset = inner_new_offset
                local inner_field_id = bit.rshift(inner_tag, 3)
                local inner_wire_type = bit.band(inner_tag, 7)
                local _inner_data, inner_val_new_offset = body_buffer:varint(inner_new_offset)
                inner_offset = inner_val_new_offset
                if inner_field_id == 1 and inner_wire_type == 2 then
                    local content = body_buffer(inner_val_new_offset,_inner_data):string(ENC_UTF_8)
                    device_info_tree:add(string.format("CPU使用率: %s", content), body_buffer(inner_val_new_offset, _inner_data))
                    inner_offset = inner_offset + _inner_data
                elseif inner_field_id == 2 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("总内存: %d GB", _inner_data), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 3 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("已用内存: %d GB", _inner_data), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 4 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("可用内存: %d GB", _inner_data), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 5 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("磁盘总空间: %d GB", _inner_data), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 6 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("磁盘已用空间: %d GB", _inner_data), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 7 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("磁盘剩余空间: %d GB", _inner_data), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 8 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("传感器通讯状态: %s", sensor_status_map[_inner_data]), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 9 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("摄像机通讯状态: %s", sensor_status_map[_inner_data]), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                elseif inner_field_id == 10 and inner_wire_type == 0 then
                    device_info_tree:add(string.format("报警通讯状态: %d", _inner_data), body_buffer(inner_new_offset, inner_val_new_offset - inner_new_offset))
                end

            end
        end
    end

end

function parser_defence_send(body_buffer, body_tree, data_length_int)
	-- 解析布撤防发送
	local offset = 0
    while offset < data_length_int do
        local tag, new_offset = body_buffer:varint(offset)
        offset = new_offset
        local field_id = bit.rshift(tag, 3)
        local wire_type = bit.band(tag, 7)
		local _data, val_new_offset = body_buffer:varint(offset)
		offset = val_new_offset
        if field_id == 1 and wire_type == 2 then
			local content = body_buffer(val_new_offset, _data):string(ENC_UTF_8)
            body_tree:add(string.format("设备编码: %s", content), body_buffer(val_new_offset, _data))
			offset = offset + _data
        elseif field_id == 2 and wire_type == 0 then
            body_tree:add(string.format("布撤防: %d", defence_status_map[_data]), body_buffer(new_offset, val_new_offset - new_offset))
        end
    end
end


function parser_log_send(body_buffer, body_tree, data_length_int)
	-- 解析日志发送
	local offset = 0
    while offset < data_length_int do
        local tag, new_offset = body_buffer:varint(offset)
        offset = new_offset
        local field_id = bit.rshift(tag, 3)
        local wire_type = bit.band(tag, 7)
		local _data, val_new_offset = body_buffer:varint(offset)
		offset = val_new_offset + _data
		if field_id == 1 and wire_type == 2 then
		    local message = body_buffer(val_new_offset, _data):string(ENC_UTF_8)
		    body_tree:add(string.format("指令: %s", message), body_buffer(val_new_offset, _data))
        elseif field_id == 2 and wire_type == 2 then
            local message = body_buffer(val_new_offset, _data):string(ENC_UTF_8)
            body_tree:add(string.format("下发时间: %s", message), body_buffer(val_new_offset, _data))
        end
    end
end

function parser_server_receive(body_buffer, body_tree, data_length_int)
	-- 解析布撤防回复
	local offset = 0
    while offset < data_length_int do
        local tag, new_offset = body_buffer:varint(offset)
        offset = new_offset
        local field_id = bit.rshift(tag, 3)
        local wire_type = bit.band(tag, 7)
		local _data, val_new_offset = body_buffer:varint(offset)
		offset = val_new_offset
        if field_id == 1 and wire_type == 0 then
			body_tree:add(string.format("状态码: %d", _data), body_buffer(new_offset, val_new_offset - new_offset))
        elseif field_id == 2 and wire_type == 2 then
			local message = body_buffer(val_new_offset, _data):string(ENC_UTF_8)
            body_tree:add(string.format("消息: %s", message), body_buffer(val_new_offset,_data))
			offset = offset + _data
		elseif field_id == 3 and wire_type == 2 then
			local message = body_buffer(val_new_offset, _data):string(ENC_UTF_8)
            body_tree:add(string.format("设备编码: %s", message), body_buffer(val_new_offset,_data))
			offset = offset + _data
		elseif field_id == 4 and wire_type == 0 then
			body_tree:add(string.format("布撤防状态: %d", defence_status_map[_data]), body_buffer(new_offset, val_new_offset - new_offset))
        end
    end
end


function parser_heartbeat_send(body_buffer, body_tree, data_length_int)
    -- 解析心跳
    local offset = 0
    while offset < data_length_int do
        local tag, new_offset = body_buffer:varint(offset)
        offset = new_offset
        local field_id = bit.rshift(tag, 3)
        local wire_type = bit.band(tag, 7)
        local _string_len, val_new_offset = body_buffer:varint(offset)
        local content = body_buffer(val_new_offset,_string_len):string(ENC_UTF_8)
        if field_id == 1 and wire_type == 2 then
            body_tree:add(string.format("设备编码: %s", content), body_buffer(val_new_offset, _string_len))
        end
        offset = val_new_offset + _string_len
    end

end
--
--function parser_server_receive(body_buffer, body_tree, data_length_int)
--	-- 解析认证回复
--	local offset = 0
--    while offset < data_length_int do
--        local tag, new_offset = body_buffer:varint(offset)
--        offset = new_offset
--        local field_id = bit.rshift(tag, 3)
--        local wire_type = bit.band(tag, 7)
--		local _data, val_new_offset = body_buffer:varint(offset)
--		offset = val_new_offset
--        if field_id == 1 and wire_type == 0 then
--            body_tree:add(string.format("状态码: %s", _data), body_buffer(new_offset, val_new_offset - new_offset))
--        elseif field_id == 2 and wire_type == 2 then
--        	local content = body_buffer(val_new_offset, _data):string(ENC_UTF_8)
--            body_tree:add(string.format("消息: %s", content), body_buffer(val_new_offset, _data))
--			offset = offset + _data
--        end
--    end
--end


-- 核心解析函数
function ofs_proto.dissector(buffer, pinfo, tree)
    -- 检查数据包长度是否足够
    if buffer:len() < 4 then
        return
    end

    -- 设置协议列显示名称
    pinfo.cols.protocol = ofs_proto.name

    -- 创建协议子树
    local subtree = tree:add(ofs_proto, buffer(), "震动光纤服务协议")

    -- 解析字段并添加到树
    subtree:add(magic, buffer(0, 2))      -- 起始位
    subtree:add_le(version, buffer(2, 2))      -- 版本号
    subtree:add_le(seq_id, buffer(4, 2))      -- 序列号
    local data_type_int = buffer(6, 1):uint()
    local function_code_str = msg_type_map[data_type_int] or string.format("未知(%02d)", data_type_int)
    subtree:add_le(msg_type, buffer(6, 1))      -- 消息类型
    local data_length_int = buffer(7,4):uint()
    subtree:add(data_length,buffer(7, 4)) -- 数据长度
    local ts_uint64 = buffer(11, 8):uint64()
    local ts_high = ts_uint64:higher()
    local ts_low = ts_uint64:lower()
    local ts_ms = 0
    if ts_high == 0 then
        -- 低32位即可表示，直接转换
        ts_ms = ts_low
    else
        -- 高32位非0，组合计算（单位：毫秒）
        ts_ms = (ts_high * 0x100000000) + ts_low
    end

    -- 3. 转换为秒和毫秒（Unix时间戳：秒级）
    local ts_sec = math.floor(ts_ms / 1000)
    local ts_ms_remain = ts_ms % 1000

    -- 4. 格式化为可读时间（UTC+8，可根据需求调整时区）
    local time_str = os.date("%Y-%m-%d %H:%M:%S", ts_sec) .. "." .. string.format("%03d", ts_ms_remain)

    -- 5. 将解析结果添加到Wireshark解析树
    subtree:add(timestamp, buffer(11, 8))  -- 时间戳
    subtree:add(timestamp_format, time_str):set_generated(true) -- 标记为生成字段 时间戳格式化
    subtree:add(nonce, buffer(19, 4))  -- 随机数
    subtree:add(reserved, buffer(23, 1))  -- 预留数据
    subtree:add(sm3_checksum, buffer(24, 32))  -- 校验码
    local data_body_tree = subtree:add(data_body, buffer(56, data_length_int)) --消息体
    if data_type_int == 0x00 then
		-- 身份验证发送
        parser_auth_send(buffer(56, data_length_int),data_body_tree, data_length_int)
	elseif data_type_int == 0x02 then
		-- 心跳发送
		parser_heartbeat_send(buffer(56, data_length_int),data_body_tree, data_length_int)
    elseif data_type_int == 0x08 then
        -- 布撤防控制
        parser_defence_send(buffer(56, data_length_int), data_body_tree, data_length_int)
    elseif data_type_int == 0x10 then
        -- 日志控制
        parser_log_send(buffer(56, data_length_int), data_body_tree, data_length_int)
        elseif data_type_int == 0x06 then

    elseif (data_type_int == 0x01 or data_type_int == 0x03 or  data_type_int == 0x07 or data_type_int == 0x09 or data_type_int == 0x11) then
		-- 回复
		parser_server_receive(buffer(56, data_length_int),data_body_tree, data_length_int)
	end
    pinfo.cols.info = string.format("消息类型: %s", function_code_str)
end
-- 注册协议到指定端口
local udp_table = DissectorTable.get("tcp.port")
udp_table:add(5001, fc_proto)
