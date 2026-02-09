-- 定义协议（协议标识符和显示名称）
of_proto = Proto("of", "of")

-- 共用数据
-- 头部
header = ProtoField.uint16("of.header", "头部字段", base.HEX)
-- 设备ID
func_map = {
    [0] = "心跳",
    [1] = "报警"
}
func_code = ProtoField.uint8("of.func_code", "功能码", base.DEC,func_map)
-- 定义协议字段（字段标识符、显示名称、数据格式）
of_proto.fields = {header, func_code}

function of_proto.dissector(buffer, pinfo, tree)
    -- 检查数据包长度是否足够
    if buffer:len() < 7 then
        return
    end

    -- 设置协议列显示名称
    pinfo.cols.protocol = of_proto.name

    -- 创建协议子树
    local subtree = tree:add(of_proto, buffer(), "光纤协议")

    -- 解析字段并添加到树
    subtree:add(header, buffer(0, 2))      -- 头部
    subtree:add(func_code, buffer(2, 1))      -- 功能码
    local func_code_str = func_map[buffer(2, 1):uint()]
    local data_length_int = buffer:range(3, 4):le_uint()
    subtree:add(buffer(3, 4), string.format("数据长度:%d", data_length_int ))
    subtree:add(
        buffer:range(7, data_length_int),
        string.format("数据区域:%s",buffer:range(7, data_length_int):string(ENC_UTF_8))
        )    -- 长度


    -- 设置信息列摘要

    pinfo.cols.info = string.format("数据类型: %s",  func_code_str)
end

-- 注册协议到指定端口
local udp_table = DissectorTable.get("tcp.port")
udp_table:add(5554, of_proto)
