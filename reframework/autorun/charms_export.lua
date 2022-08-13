

log.info("[Charms Export] initializing...")

local ARMOR_ID_TYPE = 2
local TALISMAN_ID_TYPE = 3

-- https://stackoverflow.com/a/27028488/3142238
function json_dump(o)
  if type(o) == 'table' then
     local s = ''
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s ..k..':' .. json_dump(v) .. ', '
     end
     return '{ ' .. string.sub(s, 1, -3) .. ' }'
  else
     return tostring(o)
  end
end


local _log = function(str)
  log.debug("[Charms Export] " .. tostring(str or ""));
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
local armorToObject = function(item)
  -- local isArmor = item:call("isArmor")
  -- _log(tostring(isArmor));
  -- _log(tostring(item:call("getName")))
  -- _log(tostring(item:call("getArmorData")))

  local armorData = item:call("getArmorData"); -- snow.data.ArmorData
  local baseData = armorData:call("get_BaseData"); -- snow.data.ArmorBaseData


  local allDecoSlotList = armorData:call("get_AllDecoSlotList");
  -- snow.data.equip.param.DecorationsSlotData
  local allSkillDataList = armorData:call("get_AllSkillDataList");

  local baseDecoSlotList = baseData:call("get_DecorationsSlotNumList");
  local baseSkillDataList = baseData:call("get_AllSkillDataList");
  local baseRegData = baseData:call("get_RegData"); -- snow.data.ArmorElementRegData


  local skillObject = {}
  
  local count = allSkillDataList:call("get_Count")
  for i = 0,count-1,1 do
    local skillData = allSkillDataList:call("get_Item", i);
    if skillData:call("get_EquipSkillId") ~= 0 then
      skillObject[skillData:call("get_Name")] = skillData:call("get_TotalLv")
    end
  end

  local skillDiffObject = {}
  local activeSkillDataList = armorData:call("getCustomSkillUpList");
  count = activeSkillDataList:call("get_Count")
  for i = 0,count-1,1 do
    local skillData = activeSkillDataList:call("get_Item", i);
    if skillData:call("get_EquipSkillId") ~= 0 then
      skillDiffObject[skillData:call("get_Name")] = skillData:call("get_TotalLv")
    end
  end
  activeSkillDataList = armorData:call("getCustomSkillDownList");
  count = activeSkillDataList:call("get_Count")
  for i = 0,count-1,1 do
    local skillData = activeSkillDataList:call("get_Item", i);
    if skillData:call("get_EquipSkillId") ~= 0 then
      skillDiffObject[skillData:call("get_Name")] = skillData:call("get_TotalLv")
    end
  end


  local decoSlot = {};
  local baseSlot = {};
  count = allDecoSlotList:call("get_Count");
  for i=0,count-1,1 do
    -- snow.data.DecorationBaseData
    table.insert(decoSlot, allDecoSlotList:call("get_Item", i):call("getSlotLv"));
  end

  local decoSlotList = armorData:call("getOriginalSlotLvTable");
  count = decoSlotList:call("get_Count")
  for i=0,count-1,1 do
    table.insert(baseSlot, decoSlotList:call("get_Item", i));
  end;

  table.sort(decoSlot, function (l, r) return l > r; end);
  table.sort(baseSlot, function (l, r) return l > r; end);


  local decoDiff = {}
  for i=1,3,1 do
    table.insert(decoDiff, (decoSlot[i] or 0) - (baseSlot[i] or 0));
  end

  -- _log("deco: " .. json_dump(decoSlot) .. json_dump(baseSlot) .. json_dump(decoDiff));

  -- local orgSlotList = {}
  -- local orgDecoSlotList = armorData:call("get_OrgDecorationSlotNumList");
  -- count = orgDecoSlotList:call("get_Count")
  -- for i=0,count-1,1 do
  --   orgSlotList[i] = orgDecoSlotList:call("get_Item", i)
  -- end;

  local defDiff = ( armorData:call("getDefVal") or 0 ) - (
    armorData:call("getArmorBuildupDef") or 0
  ) - baseData:call("get_DefVal");

  local elemRegDiff = {}
  for i = 0,4,1 do
    elemRegDiff[i] = armorData:call("getRegData", i):call("get_RegVal") - (
      baseRegData:call("getParam", i):call("get_RegVal")
    );
  end;

  local armorString = string.format(
    "%s ___ %s ___ %s ___ %d,%s",
    armorData:call("getName"),
    json.dump_string(decoDiff),
    json_dump(skillDiffObject),defDiff,
    json.dump_string(elemRegDiff)
  )
  -- _log(armorString)


  local def_and_elem_diff = {
    defDiff,
    table.unpack(elemRegDiff)
  }
  return {
    armorData:call("getName"),
    defDiff,
    string.sub(json.dump_string(elemRegDiff), 2, -2),
    json.dump_string(decoDiff),
    json_dump(skillDiffObject),
    -- table.concat(elemRegDiff, ",")
  };

  -- tostring(item:call("get_BuildupPoint"))
end

local function armorToString(arg)
  return string.format(
    "[\"%s\",%s,%s,%s,%s], ",
    table.unpack(armorToObject(arg))
  )
end



local function getExportingData()
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
      if item:call("getArmorData"):call("get_CustomEnable") then
        _= armorsStringList << armorToString(item)
      end
      

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
local armorsFileName = "exported_armors.js"
re.on_draw_ui(function()
  if imgui.button(
    "[Charms Export] export charms & armor to " ..
    "reframework/data/" .. charmsFileName .. " and " ..
    "reframework/data/" .. armorsFileName
  ) then
    
    -- local output = table.concat(charmsStringList, "\n");
    local output = getExportingData() or {}

    local charmsStringList = output["charms"] or {}
    local armorsStringList = output["armors"] or {}

    local js_src = [[
;(async function(){

  let closeButton = null;
  while(( closeButton = document.querySelector(
      `span[class="glyphicon glyphicon-remove"]`
  ))){
      
    closeButton.parentElement.click();
    closeButton.dispatchEvent(new Event("click", {
      bubbles: true
    }));
    await new Promise(res => setTimeout(res, 10));
  }
   
  let armors = [
]] .. (
  table.concat(armorsStringList, "\n")
) .. [[
  ];

let i = 0;
async function performAdding(armor){
  if(!armor) return;
  console.log(armor);
  
  const selects = [ ...document.querySelectorAll("select") ]
  const submitButton = document.querySelector("button");
  
  const setSelect = async (i, value) => {
      
      selects[i].value = value;
      let childOption = selects[i].querySelector(`option[value="${value}"]`);
      
      console.log("setSelect", i, value, childOption);
      if(childOption){
        childOption.dispatchEvent(new Event("click", {
          bubbles: true 
        }));
      }
      if(selects && selects[i]){
        selects[i].dispatchEvent(new Event('change', {
            bubbles: true
        }));
      }
      
      
    // await new Promise(res => setTimeout(res, 0));
  };
  
  await setSelect(0, armor[0].replace("･", "・"));
  for(let i of [1,2,3,4,5,6]){
      await setSelect(i, armor[i].toString());
  }
  
  let slots = armor[7];
  for(let i of [0, 1, 2]){
      await setSelect(7+i, slots[i].toString());
  }
  
  let skills = armor[8];
  let startFrom = 10;
  let skillEntries = Object.entries(skills);
  for(let i of [0, 1, 2, 3]){
      let [ skillName, skillLvDiff ] = skillEntries[i] || [ "", 0 ];
      
      await setSelect(startFrom++, skillName);
      await setSelect(startFrom++, skillLvDiff.toString());
  }
  
  await new Promise(res => setTimeout(res, 0));
  
  let click_result = submitButton.click();
  
  if(armors.length){
      setTimeout(() => {
          performAdding(armors.pop());
      }, 0);
  }
}

performAdding(armors.pop());
      
}());
    ]]
    if saveToFile then
      saveToFile(
          "reframework/data/" .. charmsFileName,
          table.concat(charmsStringList, "\n")
          
      );
      saveToFile(
          "reframework/data/" .. armorsFileName, js_src
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


log.info("[Charms Export] initialized.")