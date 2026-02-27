local bit = require("bit")   -- 已自带，直接 require
-- 定义协议（协议标识符和显示名称）
ofs_proto = Proto("ofs", "震动光纤服务协议")

auth_valid = {
    send = 0x00,
    send_value= "用户身份识别请求",
    recv = 0x01,
    recv_value = "用户身份识别响应"
}

heartbeat_code = {
    send = 0x02,
    recv = 0x03,
    send_value = "心跳请求",
    recv_value = "心跳响应"
}

device_status_code = {
    send = 0x06,
    recv = 0x07,
    send_value = "设备状态请求",
    recv_value = "设备状态回复"
}
defence_control_code = {
    send = 0x08,
    recv = 0x09,
    send_value = "布撤防控制",
    recv_value = "布撤防回复"
}
log_control_code = {
    send = 0x10,
    recv = 0x11,
    send_value = "日志上报",
    recv_value = "日志上报回复"
}

-- 共用数据
msg_type_map = {
    [auth_valid.send] = auth_valid.send_value,
    [auth_valid.recv] = auth_valid.recv_value,
    [heartbeat_code.send] = heartbeat_code.send_value,
    [heartbeat_code.recv] = heartbeat_code.recv_value,
    [device_status_code.send] = device_status_code.send_value,
    [device_status_code.recv] = device_status_code.recv_value,
    [defence_control_code.send] = defence_control_code.send_value,
    [defence_control_code.recv] = defence_control_code.recv_value,
    [log_control_code.send] = log_control_code.send_value,
    [log_control_code.recv] = log_control_code.recv_value
}

proto_code_map = {
    [auth_valid.send] = {
     ["file"] = "device_status.proto",
     ["type"] = "message,AuthRequest"
    },
    [auth_valid.recv] = {
     ["file"] = "device_status.proto",
     ["type"] = "message,AuthResponse"
    },
    [heartbeat_code.send] = {
     ["file"] = "heartbeat.proto",
     ["type"] = "message,HeartbeatRequest"
    },
    [heartbeat_code.recv] = {
     ["file"] = "heartbeat.proto",
     ["type"] = "message,HeartbeatResponse"
    },
    [defence_control_code.send] = {
     ["file"] = "alarm_control.proto",
     ["type"] = "message,AlarmControlRequest"
    },
    [defence_control_code.recv] = {
     ["file"] = "alarm_control.proto",
     ["type"] = "message,AlarmControlResponse"
    },
    [log_control_code.send] = {
     ["file"] = "log_service.proto",
     ["type"] = "message,UploadLogsRequest"
    },
    [log_control_code.recv] = {
     ["file"] = "log_service.proto",
     ["type"] = "message,UploadLogsResponse"
    },
    [device_status_code.send] = {
     ["file"] = "device_status.proto",
     ["type"] = "message,DeviceStatusRequest"
    },
    [device_status_code.recv] = {
     ["file"] = "device_status.proto",
     ["type"] = "message,DeviceStatusResponse"
    },
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
--timestamp = ProtoField.int64("ofs.time_stamp", "时间戳", base.DEC)
timestamp = ProtoField.absolute_time("ofs.time_stamp", "时间戳", base.LOCAL)
timestamp_format = ProtoField.string("ofs.time_format", "时间戳解析", base.NONE)
--随机数
nonce = ProtoField.bytes("ofs.nonce", "随机数", base.NONE)
-- 预留
reserved = ProtoField.uint8("ofs.reserved", "预留", base.HEX)
-- 校验码
sm3_checksum = ProtoField.bytes("ofs.sm3_check", "校验码", base.NONE)
-- 消息体
data_body = ProtoField.bytes("ofs.body", "消息体", base.NONE)
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
function file_exist(file_name, subtree)
    local f = io.open(file_name, "r")
        if not f then
            subtree:add_expert_info(PI_ERROR, PI_UNSUPPORTED, "Proto 文件不存在：" .. proto_file)
            return
        end
        f:close()
end

-- 核心解析函数
function ofs_proto.dissector(buffer, pinfo, tree)
    local src_port = pinfo.src_port  -- 源端口（数值类型，如 8080）
    local dst_port = pinfo.dst_port  -- 目的端口（数值类型，如 12345）
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
    subtree:add(version, buffer(2, 2))      -- 版本号
    subtree:add(seq_id, buffer(4, 2))      -- 序列号
    local data_type_int = buffer(6, 1):uint()
    local function_code_str = msg_type_map[data_type_int] or string.format("未知(%02d)", data_type_int)
    subtree:add(msg_type, buffer(6, 1))      -- 消息类型
    local data_length_int = buffer(7,4):uint()
    subtree:add(data_length,buffer(7, 4)) -- 数据长度
    local timestamp_ms = buffer(11, 8):uint64()  -- 返回 UInt64 对象
    local secs = timestamp_ms / 1000       -- 整数除法，得到秒
    local nsecs = (timestamp_ms % 1000) * 1000000  -- 剩余毫秒转纳秒
    local nstime = NSTime.new(secs:tonumber(), nsecs:tonumber())
    subtree:add(timestamp, buffer(11, 8),nstime)  -- 时间戳
    subtree:add(nonce,buffer(19, 4))  -- 随机数
    subtree:add(reserved, buffer(23, 1))  -- 预留数据
    subtree:add(sm3_checksum,buffer(24, 32))  -- 校验码
    subtree:add(data_body, buffer(56, data_length_int)) --消息体

    local pb_dissector = Dissector.get("protobuf")
    if not pb_dissector then
        subtree:add_expert_info(PI_ERROR, PI_UNSUPPORTED, "Protobuf dissector not found")
        return
    end

    -- 3. 配置解析参数（告诉解析器用哪个 .proto 和消息类型）
    --local msg_type = "test.HeartBeat"  -- 包名+消息名
    --pinfo.private["pb_msg_type"] = msg_type
    -- 4. 调用解析器：解析结果会自动添加到 root_tree 中，无需手动加字段！
    --pb_dissector:call(buffer(56, data_length_int):tvb(), pinfo, data_body_tree)
    --
    pinfo.private["pb_proto_file"] = proto_code_map[data_type_int]["file"]
    pinfo.private["pb_msg_type"] = proto_code_map[data_type_int]["type"]
    --if data_type_int == auth_valid.send then
	--	-- 身份验证发送
	--	pinfo.private["pb_proto_file"] = "auth.proto"
    --    pinfo.private["pb_msg_type"] = "message,AuthRequest"
    --    --pb_dissector:call(buffer(56, data_length_int):tvb(), pinfo, subtree)
	--elseif data_type_int == heartbeat_code.send then
	--	-- 心跳发送
	--	pinfo.private["pb_proto_file"] = "heartbeat.proto"
    --    pinfo.private["pb_msg_type"] = "message,HeartbeatRequest"
    --    --pcall(Dissector.call, pb_dissector, buffer(56, data_length_int):tvb(), pinfo, subtree)
    --elseif data_type_int == defence_control_code.send then
    --    -- 布撤防控制
    --    pinfo.private["pb_proto_file"] = "alarm_control.proto"
    --    pinfo.private["pb_msg_type"] = "message,AlarmControlRequest"
    --    --parser_defence_send(buffer(56, data_length_int), data_body_tree, data_length_int)
    --elseif data_type_int == log_control_code.send then
    --    -- 日志控制
    --    pinfo.private["pb_proto_file"] = "log_service.proto"
    --    pinfo.private["pb_msg_type"] = "message,UploadLogsRequest"
    --    --parser_log_send(buffer(56, data_length_int), data_body_tree, data_length_int)
    --elseif data_type_int == device_status_code.send then
    --    -- 设备状态
    --    pinfo.private["pb_proto_file"] = "device_status.proto"
    --    pinfo.private["pb_msg_type"] = "message,DeviceStatusRequest"
    --end
    pcall(Dissector.call, pb_dissector, buffer(56, data_length_int):tvb(), pinfo, subtree)
    pinfo.cols.info = string.format("%s -> %s 消息类型: %s", src_port, dst_port,function_code_str)
end
-- 注册协议到指定端口
local udp_table = DissectorTable.get("tcp.port")
udp_table:add(10009, ofs_proto)
