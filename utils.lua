-- written by jackjasonb

require "item"
require "monster"
ADDRESS = {
    R_NUM = 0x0F9BA0,
    POS_X = 0x0C7020,
    POS_Z = 0x0C7028,
    ENCOUNT_WALK = 0x0F78DC,
    MAP_ID = 0x0F74D4,
    CAMERA = 0x0DB498,
    ENEMY_1_HP = 0x0E5C66,
    ENEMY_2_HP = 0x0E5D12,
    ENEMY_3_HP = 0x0E5DBE,
    ENEMY_4_HP = 0x0E5E6A,
    ENEMY_1_NAME = 0x0E72F0,
    ENEMY_2_NAME = 0x0E72F4,
    ENEMY_3_NAME = 0x0E72F8,
    ENEMY_4_NAME = 0x0E72FC,
    ENEMY_1_NUM = 0x0E72F2,
    ENEMY_2_NUM = 0x0E72F6,
    ENEMY_3_NUM = 0x0E72FA,
    ENEMY_4_NUM = 0x0E72FE,
    ARUS_ITEM_1 = 0x010C48,
    KIEFER_ITEM_1 = 0x010D54,
    MARIBEL_ITEM_1 = 0x010E60,
    GABO_ITEM_1 = 0x010F6C,
    MELVIN_ITEM_1 = 0x011184,
    AIRA_ITEM_1 = 0x011078,
    GOLD1 = 0x0112D8,
    GOLD2 = 0x0112DA
}

function dec2hex(input)
    return string.format("%04x", input)
end

function table2str(table)
    local table_str = ""
    for i = 1, #table do
        table_str = table_str .. table[i] .. "\n"
    end
    return table_str
end

function getRNum()
    return string.format("%x", memory.read_u32_le(ADDRESS.R_NUM))
end

function getPosX()
    return memory.read_s32_le(ADDRESS.POS_X)
end

function getPosZ()
    return memory.read_s32_le(ADDRESS.POS_Z)
end

function getEncountWalk()
    return memory.read_u16_le(ADDRESS.ENCOUNT_WALK)
end

function getMapId()
    return memory.read_u32_le(ADDRESS.MAP_ID)
end

function getCamera()
    return memory.read_u32_le(ADDRESS.CAMERA)
end

function getTime()
    frame = emu.framecount()
    --hour
    hour = math.floor(frame / (60 * 60 * 60))
    frame = frame - hour * (60 * 60 * 60)
    --min
    min = math.floor(frame / (60 * 60))
    frame = frame - min * (60 * 60)
    --sec
    sec = math.floor(frame / 60)
    frame = frame - sec * 60
    --msec
    msec = math.floor(frame / 60 * 100)

    time = string.format("%02d:%02d:%02d.%02d", hour, min, sec, msec)
    return time
end

function get_items(address)
    local items = {}
    local equip = false
    for i = 0, 11 do
        local item = memory.read_u16_le(address + i * 2)
        -- アイテム装備時はアイテムの値に0x0400が加算される
        if item > 1024 then
            item = item - 1024
            equip = true
        end
        item = "i" .. string.format("%04X", item)
        if equip then
            table.insert(items, "E:" .. ITEM[item])
        else
            table.insert(items, "  " .. ITEM[item])
        end
        equip = false
    end
    return items
end

function get_gold()
    return memory.read_u32_le(ADDRESS.GOLD1)
end

function get_enemy_name(num)
    local enemy_num = memory.read_u16_le(ADDRESS.ENEMY_1_NUM)
    local enemy = MONSTER["m" .. string.format("%04X", memory.read_u16_le(ADDRESS.ENEMY_1_NAME))]
    if enemy_num < num then
        enemy = MONSTER["m" .. string.format("%04X", memory.read_u16_le(ADDRESS.ENEMY_2_NAME))]
        num = num - enemy_num
        enemy_num = memory.read_u16_le(ADDRESS.ENEMY_2_NUM)
        if enemy_num < num then
            enemy = MONSTER["m" .. string.format("%04X", memory.read_u16_le(ADDRESS.ENEMY_3_NAME))]
            num = num - enemy_num
            enemy_num = memory.read_u16_le(ADDRESS.ENEMY_3_NUM)
            if enemy_num < num then
                enemy = MONSTER["m" .. string.format("%04X", memory.read_u16_le(ADDRESS.ENEMY_4_NAME))]
            end
        end
    end

    if enemy then
        return enemy
    else
        return ""
    end
end

function get_enemy_HP(address)
    return memory.read_u16_le(address)
end
