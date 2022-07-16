

log.info("[Charms Export] initializing...")


local TALISMAN_ID_TYPE = 3



local _log = function(str)
  log.debug("[Charms Export] " .. (str or ""));
end;

_log("initializing...")


local DataManager = sdk.get_managed_singleton("snow.data.DataManager");
if not DataManager then
  _log("DataManager is empty!");
  return
end

local EquipmentBox = DataManager:get_field("_PlEquipBox");

local InventoryList = EquipmentBox:get_field("_WeaponArmorInventoryList");

local DataShortcut = sdk.find_type_definition("snow.data.DataShortcut");
local getSkillName = DataShortcut:get_method("getName(snow.data.DataDef.PlEquipSkillId)");
_log("skillName: " .. ( getSkillName:call(nil, 5) or "empty" ));


local itemCount = InventoryList:call("get_Count");
_log("item count: " .. itemCount)


local charmToString = function(item)
  local itemType = item:get_field("_IdType");
  if itemType ~= TALISMAN_ID_TYPE then -- Talisman: 3
    _log("attempt to parse non charm to string")
    return
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

local charmsStringList = {}
setmetatable(charmsStringList, { __shl = function (t,v) t[#t+1]=v end })

for i = 0,itemCount-1,1 do
  local item = InventoryList:call("get_Item(System.Int32)", i);
  local itemType = item:get_field("_IdType");

  
  if itemType == TALISMAN_ID_TYPE then -- Talisman: 3
    _= charmsStringList << charmToString(item)
  end
end

-- _log(table.concat(charmsStringList, "\n"))


_log("initialized.")



local outputFileName = "exported_charms.txt"
re.on_draw_ui(function()
	if imgui.button(
    "[Charms Export] export charms to reframework/data/" .. outputFileName
  ) then
		
    -- local output = table.concat(charmsStringList, "\n");
    local output = charmsStringList
    json.dump_file(outputFileName, output)
	end
end)


log.info("[Charms Export] initialized.")