

log.info("[Charms Export] initializing...")

local ARMOR_ID_TYPE = 2
local TALISMAN_ID_TYPE = 3

-- https://stackoverflow.com/a/27028488/3142238
function json_dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s ..k..':' .. json_dump(v) .. ', '
     end
     return string.sub(s, 1, -3) .. ' } '
  else
     return tostring(o)
  end
end


local _log = function(str)
  log.debug("[Charms Export] " .. (str or ""));
end;

local DataShortcut = sdk.find_type_definition("snow.data.DataShortcut");
local getSkillName = DataShortcut:get_method("getName(snow.data.DataDef.PlEquipSkillId)");

local charmToString = function(item)
  local itemType = item:get_field("_IdType");
  if itemType ~= TALISMAN_ID_TYPE then -- Talisman: 3
    _log("attempt to parse non charm to string")
    return ""
  end

  local repr = ""

  for i=0,1,1 do
    local skillId = item:get_field("_TalismanSkillIdList"):call("get_Item", i);
    local skillLv = item:get_field("_TalismanSkillLvList"):call("get_Item", i);

    repr = repr .. getSkillName:call(nil, skillId) .. "," .. skillLv .. ","

  end


  local slots = item:get_field("_TalismanDecoSlotNumList");
  
  local decoSlots = {0, 0, 0}
  for i = 1,4,1 do
    for j = slots:call("get_Item", i),1,-1 do
      table.insert(decoSlots, 1, i)
    end
  end

  repr = repr .. table.concat(decoSlots, ",", 1, 3)

  return repr
end


--[[

  armorData: snow.data.ArmorData

    armorData:call("get_AllDecoSlotList"):call("get_Item", 0) returns
    snow.data.equip.param.DecorationSlotsData

    armorData:call("get_AllSkillDataList")
      returns snow.data.PlSkillData


      
    local skillData = allSkillDataList:call("get_Item", i || 0);
      _log(
        tostring(skillData:call("get_EquipSkillId")) .. " " ..
        tostring(skillData:call("get_Name")) .. " " ..
        tostring(skillData:call("get_TotalLv")) .. " " ..
        tostring(skillData:call("get_EffectiveLv")) .. " " ..
        tostring(skillData:call("get_MaxLv"))
      );

--]]
local armorToString = function(item)
  -- local isArmor = item:call("isArmor")
  -- _log(tostring(isArmor));
  -- _log(tostring(item:call("getName")))
  -- _log(tostring(item:call("getArmorData")))

  local armorData = item:call("getArmorData"); -- snow.data.ArmorData
  local allDecoSlotList = armorData:call("get_AllDecoSlotList");
  local allSkillDataList = armorData:call("get_AllSkillDataList");

  local skillObject = {}
  local skillIdObject = {}

  local count = allSkillDataList:call("get_Count")
  for i = 0,count-1,1 do
    local skillData = allSkillDataList:call("get_Item", i);
    if skillData:call("get_EquipSkillId") ~= 0 then
      skillObject[skillData:call("get_Name")] = skillData:call("get_TotalLv")
      skillIdObject[skillData:call("get_EquipSkillId")] = skillData:call("get_TotalLv")
    end
  end

  local armorString = string.format(
    "\"%s\", [%d, %d, %d], %s, %s",
    armorData:call("getName"),
    allDecoSlotList:call("get_Item", 2):call("getSlotLv"),
    allDecoSlotList:call("get_Item", 1):call("getSlotLv"),
    allDecoSlotList:call("get_Item", 0):call("getSlotLv"),
    json_dump(skillObject),
    json_dump(skillIdObject)
  )

  _log(armorString);


  return armorString

  -- tostring(item:call("get_BuildupPoint"))
end



local function getCharmsStringList()
  local output = {}
  local charmsStringList = {}
  local armorsStringList = {}

  output["charms"] = charmsStringList
  output["armors"] = armorsStringList

  local DataManager = sdk.get_managed_singleton("snow.data.DataManager");
  if not DataManager then
    log.debug("DataManager is empty!");
    return charmsStringList
  end
  
  local EquipmentBox = DataManager:get_field("_PlEquipBox");
  
  local InventoryList = EquipmentBox:get_field("_WeaponArmorInventoryList");
  
  local first = true;
  
  local itemCount = InventoryList:call("get_Count");
  setmetatable(charmsStringList, { __shl = function (t,v) t[#t+1]=v end })
  setmetatable(armorsStringList, { __shl = function (t,v) t[#t+1]=v end })
  
  for i = 0,itemCount-1,1 do
    local item = InventoryList:call("get_Item(System.Int32)", i);
    local itemType = item:get_field("_IdType");

    if itemType == 2 then
      _= armorsStringList << armorToString(item)
      

      if first then
        first = false;
        _log(armorToString(item));
      end
    end;
  
    
    if itemType == TALISMAN_ID_TYPE then -- Talisman: 3
      _= charmsStringList << charmToString(item)
    end
  end

  -- _log(table.concat(charmsStringList, "\n"))
  return output
end


local saveToFile = package.loadlib(
  "reframework/autorun/charms_export/charms_export_lib.dll",
  "l_saveToFile"
)



local charmsFileName = "exported_charms.txt"
local armorsFileName = "exported_armors.txt"
re.on_draw_ui(function()
  if imgui.button(
    "[Charms Export] export charms & armor to " ..
    "reframework/data/" .. charmsFileName .. " and " ..
    "reframework/data/" .. armorsFileName
  ) then
    
    -- local output = table.concat(charmsStringList, "\n");
    local output = getCharmsStringList() or {}

    local charmsStringList = output["charms"] or {}
    local armorsStringList = output["armors"] or {}

    if saveToFile then
      saveToFile(
          "reframework/data/" .. charmsFileName,
          table.concat(charmsStringList, "\n")
      );
      saveToFile(
          "reframework/data/" .. armorsFileName,
          table.concat(armorsStringList, "\n")
      );
    else
      json.dump_file(charmsFileName, charmsStringList)
      json.dump_file(armorsFileName, armorsStringList)
    end

    --[[
    _log(table.concat(output, "\n"))
    --]]
  end
end)

_log("HEEYEY22331551");

log.info("[Charms Export] initialized.")