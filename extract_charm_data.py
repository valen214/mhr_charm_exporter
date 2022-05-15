
import csv
from dataclasses import dataclass, field
from enum import Enum
from subprocess import call
from time import sleep
import threading
import urllib.request

# https://docs.python.org/3/library/ctypes.html
import ctypes
from ctypes import *
from ctypes import wintypes as w
from ctypes.wintypes import *
from typing import ClassVar

KEYEVENTF_SCANCODE = 0x8
KEYEVENTF_UNICODE = 0x4
KEYEVENTF_KEYUP = 0x2
INPUT_KEYBOARD = 1
INPUT_MOUSE = 0

MOUSEEVENTF_MOVE = 0x0001
MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_RIGHTDOWN = 0x0008
MOUSEEVENTF_RIGHTUP = 0x0010

WM_HOTKEY = 0x0312

# scancode
SHIFT = 0x002A
SPACE = 0x39

VK_SHIFT = 0x10
VK_ESCAPE = 0x1B
VK_LSHIFT = 0xA0
VK_KEY_A = 0x41
VK_KEY_E = 0x45
VK_KEY_F = 0x46
VK_KEY_G = 0x47
VK_KEY_W = 0x57

MAPVK_VK_TO_VSC = 0
MAPVK_VSC_TO_VK = 1
MAPVK_VK_TO_CHAR = 2
MAPVK_VSC_TO_VK_EX = 3
MAPVK_VK_TO_VSC_EX = 4

# https://docs.microsoft.com/en-us/windows/win32/memory/memory-protection-constants
PAGE_READONLY           = 0x02
PAGE_EXECUTE_READ       = 0x20
PAGE_EXECUTE_READWRITE  = 0x40

# not defined by wintypes
ULONG_PTR = c_ulong if sizeof(c_void_p) == 4 else c_ulonglong

class KEYBDINPUT(Structure):
    _fields_ = [('wVk' ,WORD),
                ('wScan',WORD),
                ('dwFlags',DWORD),
                ('time',DWORD),
                ('dwExtraInfo',ULONG_PTR)]

class MOUSEINPUT(Structure):
    _fields_ = [('dx' ,LONG),
                ('dy',LONG),
                ('mouseData',DWORD),
                ('dwFlags',DWORD),
                ('time',DWORD),
                ('dwExtraInfo',ULONG_PTR)]

class HARDWAREINPUT(Structure):
    _fields_ = [('uMsg' ,DWORD),
                ('wParamL',WORD),
                ('wParamH',WORD)]

class DUMMYUNIONNAME(Union):
    _fields_ = [('mi',MOUSEINPUT),
                ('ki',KEYBDINPUT),
                ('hi',HARDWAREINPUT)] 

class INPUT(Structure):
    _anonymous_ = ['u']
    _fields_ = [('type',DWORD),
                ('u',DUMMYUNIONNAME)]


user32 = WinDLL('user32')
user32.SendInput.argtypes = UINT,POINTER(INPUT),c_int
user32.SendInput.restype = UINT

user32.MapVirtualKeyA.argtypes = UINT,UINT
user32.MapVirtualKeyA.restype = UINT

user32.FindWindowExW.argtypes = HWND,HWND,LPCWSTR,LPCWSTR
user32.FindWindowExW.restype = HWND

user32.GetWindowTextW.argtypes = HWND,LPWSTR,INT
user32.GetWindowTextW.restype = INT

WNDENUMPROC = WINFUNCTYPE(BOOL, HWND, LPARAM)
user32.EnumWindows.argtypes = WNDENUMPROC,LPARAM


kernel32 = WinDLL("kernel32")
kernel32.GetLastError.restype = DWORD

kernel32.ReadProcessMemory.argtypes = HWND,LPCVOID,LPVOID,INT,PINT
kernel32.ReadProcessMemory.restype = BOOL

kernel32.VirtualProtectEx.argtypes = HWND,LPCVOID,c_size_t,DWORD,PDWORD
kernel32.VirtualProtectEx.restype = BOOL

oleacc = WinDLL("oleacc")

def send_scancode(code):
    i = INPUT()
    i.type = INPUT_KEYBOARD
    i.ki = KEYBDINPUT(0,code,KEYEVENTF_SCANCODE,0,0)
    user32.SendInput(1,byref(i),sizeof(INPUT))
    i.ki.dwFlags |= KEYEVENTF_KEYUP
    user32.SendInput(1,byref(i),sizeof(INPUT))

def send_unicode(s):
    i = INPUT()
    i.type = INPUT_KEYBOARD
    for c in s:
        i.ki = KEYBDINPUT(0,ord(c),KEYEVENTF_UNICODE,0,0)
        user32.SendInput(1,byref(i),sizeof(INPUT))
        sleep(0.1)
        i.ki.dwFlags |= KEYEVENTF_KEYUP
        user32.SendInput(1,byref(i),sizeof(INPUT))

def right_click():
    i = INPUT()
    i.type = INPUT_MOUSE
    i.mi = MOUSEINPUT(0, 0, 0, MOUSEEVENTF_RIGHTDOWN, 0, 0)
    user32.SendInput(1,byref(i),sizeof(INPUT))
    sleep(0.1)
    i.mi = MOUSEINPUT(0, 0, 0, MOUSEEVENTF_RIGHTUP, 0, 0)
    user32.SendInput(1,byref(i),sizeof(INPUT))

def key_down(k):
    i = INPUT()
    i.type = INPUT_KEYBOARD
    i.ki = KEYBDINPUT(0,k,KEYEVENTF_UNICODE,0,0)
    user32.SendInput(1,byref(i),sizeof(INPUT))

def key_up(k):
    i = INPUT()
    i.type = INPUT_KEYBOARD
    i.ki = KEYBDINPUT(
        0,k,
        KEYEVENTF_UNICODE | KEYEVENTF_KEYUP,
        0,0
    )
    user32.SendInput(1,byref(i),sizeof(INPUT))

def scancode_down(s):
    i = INPUT()
    i.type = INPUT_KEYBOARD
    i.ki = KEYBDINPUT(0,s,KEYEVENTF_SCANCODE,0,0)
    user32.SendInput(1,byref(i),sizeof(INPUT))

def scancode_up(s):
    i = INPUT()
    i.type = INPUT_KEYBOARD
    i.ki = KEYBDINPUT(0,s,KEYEVENTF_SCANCODE|KEYEVENTF_KEYUP,0,0)
    user32.SendInput(1,byref(i),sizeof(INPUT))

# print(user32.MapVirtualKeyA(VK_LSHIFT, MAPVK_VK_TO_VSC))
# print(user32.MapVirtualKeyA(VK_SHIFT, MAPVK_VK_TO_VSC))

SCANCODE_A = user32.MapVirtualKeyA(VK_KEY_A, MAPVK_VK_TO_VSC)
SCANCODE_E = user32.MapVirtualKeyA(VK_KEY_E, MAPVK_VK_TO_VSC)
SCANCODE_F = user32.MapVirtualKeyA(VK_KEY_F, MAPVK_VK_TO_VSC)
SCANCODE_G = user32.MapVirtualKeyA(VK_KEY_G, MAPVK_VK_TO_VSC)
SCANCODE_W = user32.MapVirtualKeyA(VK_KEY_W, MAPVK_VK_TO_VSC)


def getWindowHandleByName(name, callback=None):
    hwnd = None

    LIMIT = 127
    def processHwnd(_hwnd, lParam):
        nonlocal hwnd

        buf = create_unicode_buffer(LIMIT)
        user32.GetWindowTextW(_hwnd, buf, LIMIT)

        title = buf.value
        if name in title:
            print(f"{repr(title)} found, hwnd: {_hwnd}")
            hwnd = _hwnd
            return False

        return True

    user32.EnumWindows(WNDENUMPROC(processHwnd), 42)
    if callable(callback):
        callback(hwnd)

    return hwnd


def escapeHook():
    # user32.GetRawInputData()

    user32.RegisterHotKey(None, 1, 0, VK_ESCAPE)

    # Wait for hotkey to be triggered
    print("\n*** Waiting for hotkey message...")
    try:
        msg = MSG()
        while user32.GetMessageA(byref(msg), None, 0, 0) != 0:
            if msg.message == WM_HOTKEY:
                print("escape pressed")
                break
            user32.TranslateMessage(byref(msg))
            user32.DispatchMessageA(byref(msg))

    # Unregister hotkey
    finally:
        user32.UnregisterHotKey(None, 1)



DataManagerAddress = LPVOID(0x14C0578C0)

def getDataManager(phwnd):
    """
https://github.com/Fexty12573/mhr-charm-item-editor/
blob/master/RisePCItemEditor/Window.cpp#L149

    """
    dataManager = UINT()
    oldProtect = DWORD()

    success = kernel32.VirtualProtectEx(
            phwnd,
            DataManagerAddress,
            sizeof(DWORD),
            PAGE_EXECUTE_READWRITE,
            byref(oldProtect)
    )

    if not success:
        last_error = GetLastError()
        print(f"VirtualProtectEx failed: {last_error}")
        return None

    success = kernel32.ReadProcessMemory(
            phwnd,
            DataManagerAddress,
            byref(dataManager),
            sizeof(PUINT),
            None
    )
    if not success:
        last_error = GetLastError()
        print(f"ReadProcessMemory failed: {last_error}")
        return None

    success = kernel32.VirtualProtectEx(
            phwnd,
            DataManagerAddress,
            sizeof(DWORD),
            oldProtect,
            byref(oldProtect)
    )
    if not success:
        last_error = GetLastError()
        print(f"VirtualProtectEx 2 failed: {last_error}")
        return None


    return dataManager.value



    

#define RPM(addr, buffer, size) ReadProcessMemory(ProcessHandle, LPVOID(addr), buffer, size, NULL)
@dataclass
class Offsets:
    EquipmentBox = 0x80
    EquipmentList = 0x28
    EquipmentItems = 0x10
    EquipmentSize = 0x18

    # https://github.com/Fexty12573/mhr-charm-item-editor/blob/master/RisePCItemEditor/Data.h#L84
    EQ_TYPE = 0x2C
    RARITY = 0x30

    SLOTS = 0x70
    LEVEL1_SLOTS = 0x24
    LEVEL2_SLOTS = 0x28
    LEVEL3_SLOTS = 0x2C

    SKILLS = 0x78
    SKILL1_ID = 0x20
    SKILL2_ID = 0x21

    LEVELS = 0x80
    SKILL1_LVL = 0x20
    SKILL2_LVL = 0x24

EquipementType = c_uint32
class EquipementTypeEnum(Enum):
    Empty = 0
    Weapon = 1
    Armor = 2
    Talisman = 3
    LvBuffCage = 4

def isCTypes(any):
    return (
        isinstance(any, type(DWORD)) and
        isinstance(any, type(UINT)) and
        callable(any)
    )

class RarityEnum(Enum):
	Rarity1 = 0x10100000,
	Rarity2 = 0x10100001,
	Rarity3 = 0x10100002,
	Rarity4 = 0x10100003,
	Rarity5 = 0x10100004,
	Rarity6 = 0x10100005,
	Rarity7 = 0x10100006,
	Rarity4_Novice = 0x10100007,
	Rarity3_Kinship = 0x10100008,
	Rarity12 = 0x10100009,
	Rarity2_Legacy = 0x1010000A



@dataclass
class Charm:
    SkillNames: ClassVar

    index: int = field(init=False)
    rarity: int = field(init=False)
    Skill1: int = field(init=False)
    Skill2: int = field(init=False)
    Skill1Level: int = field(init=False)
    Skill2Level: int = field(init=False)

    Level1Slots: int = field(init=False)
    Level2Slots: int = field(init=False)
    Level3Slots: int = field(init=False)



    def toExportString(self):
        if not Charm.SkillNames:
            raise Exception("skill names is not imported")
        return ",".join([
            str(Charm.SkillNames.get(self.Skill1)),
            str(self.Skill1Level),
            str(Charm.SkillNames.get(self.Skill2)),
            str(self.Skill2Level),
            str(self.Level1Slots),
            str(self.Level2Slots),
            str(self.Level3Slots),
        ])

    @classmethod
    def loadSkillNamesFromCSVFile(cls, file):
        with open(file, newline="", encoding="utf-8") as csvFile:
            skills = csv.reader(csvFile, delimiter=',')
            
            cls.SkillNames = {}
            for id, name in skills:
                cls.SkillNames[int(id)] = name

    @classmethod
    def loadSkillNamesFromOnlineCSVUrl(cls, url):
        with urllib.request.urlopen(url) as f:
            cls.SkillNames = {}
            for line in f.read().decode('utf-8').split("\n"):
                if not line: continue
                id, name = line.split(',')
                cls.SkillNames[int(id)] = name



def getCharmsFromEquipmentBox(phwnd, dataManager) -> list[Charm]:
    charms = []

    def RPM(type_or_buffer, baseAddress):
        if isCTypes(type_or_buffer):
            buf = type_or_buffer()
            success = kernel32.ReadProcessMemory(
                phwnd,
                LPVOID(baseAddress),
                byref(buf),
                sizeof(POINTER(type_or_buffer)),
                None
            )
            return buf if success else None
        else:
            return kernel32.ReadProcessMemory(
                phwnd,
                LPVOID(baseAddress),
                byref(type_or_buffer),
                sizeof(pointer(type_or_buffer)),
                None
            )

    eqBox = RPM(UINT, dataManager + Offsets.EquipmentBox)

    eqList = RPM(UINT, eqBox.value + Offsets.EquipmentList)
    size = RPM(UINT, eqList.value + Offsets.EquipmentSize)
    RPM(eqList, eqList.value + Offsets.EquipmentItems)

    eqList.value += Offsets.EquipmentList


    for i in range(size.value):
        item = RPM(UINT, eqList.value)
        if item.value:
            eqType = RPM(EquipementType, item.value + Offsets.EQ_TYPE)
            if eqType and eqType.value == EquipementTypeEnum.Talisman.value:
                charm = Charm()

                value = RPM(c_uint32, item.value + Offsets.RARITY)
                charm.index = i
                charm.rarity = value.value

                subptr = RPM(c_ulonglong, item.value + Offsets.SLOTS) # UINT for 32bit, I think

                charm.Level1Slots = RPM(c_uint32, subptr.value + Offsets.LEVEL1_SLOTS).value
                charm.Level2Slots = RPM(c_uint32, subptr.value + Offsets.LEVEL2_SLOTS).value
                charm.Level3Slots = RPM(c_uint32, subptr.value + Offsets.LEVEL3_SLOTS).value
                
                RPM(subptr, item.value + Offsets.SKILLS)
                charm.Skill1 = RPM(c_uint8, subptr.value + Offsets.SKILL1_ID).value & 0xFF
                charm.Skill2 = RPM(c_uint8, subptr.value + Offsets.SKILL2_ID).value & 0xFF
                
                RPM(subptr, item.value + Offsets.LEVELS)
                charm.Skill1Level = RPM(c_uint32, subptr.value + Offsets.SKILL1_LVL).value
                charm.Skill2Level = RPM(c_uint32, subptr.value + Offsets.SKILL2_LVL).value

                # print(charm.rarity)
                charms.append(charm)

                
        eqList.value += 0x8
    return charms


def main():
    hwnd = getWindowHandleByName("MonsterHunterRise")
    phwnd = oleacc.GetProcessHandleFromHwnd(hwnd)

    # print(sizeof(POINTER(DWORD)))
    # print(sizeof(pointer(DWORD())))

    dataManager = getDataManager(phwnd)
    print(dataManager)


    a = UINT(3)
    b = pointer(a)

    b.contents = UINT(6)
    print(b.contents.value)

    charms = getCharmsFromEquipmentBox(phwnd, dataManager)

    online = True
    if online:
        # make sure it starts with https://raw.
        Charm.loadSkillNamesFromOnlineCSVUrl(
            'https://raw.githubusercontent.com/Fexty12573/' +
            'mhr-charm-item-editor/master/RisePCItemEditor/' +
            'lang/skills_English.csv'

            # "lang/skills_Español.csv
            # "lang/skills_zhTW.csv
        )
    else:
        Charm.loadSkillNamesFromCSVFile("skills_English.csv")
    # print(Charm.SkillNames)
    data = ("\n".join(map(lambda c: c.toExportString(), charms)))
    print(data)
    
    with open("charms_data.csv", "w", encoding="utf-8") as f:
        f.write(data)



if __name__ == "__main__":
    main()
