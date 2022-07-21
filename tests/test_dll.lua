

function sep()
  print(string.rep("====", 15))
end



print("package.cpath: " .. package.cpath)
print("Test dll saveToFile()");


local saveToFile = package.loadlib(
  "reframework\\autorun\\charms_export\\charms_export_lib.dll",
  "l_saveToFile"
)

if saveToFile then
  print("saveToFile loaded");
  saveToFile("tests/output/abc.txt", "HEY" .. os.time());
end

function no()

  sep()
  print("third way to load dll")
  sep()
  local idk = package.loadlib(
    "reframework/autorun/charms_export/charms_export_lib.dll",
    'saveToFile'
  )
  
  print(idk)
  
  sep()
  print("second way to load dll")
  sep()
  local fooDll = require("reframework/autorun/charms_export/charms_export_lib")
  
  print("fooDll: " .. (fooDll or ""))

end
