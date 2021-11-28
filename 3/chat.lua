term.setBackgroundColor(colors.gray)
term.setTextColor(colors.white)

term.clear()
local run=true
local modem = peripheral.find("modem")
if not modem then
    error("No modem detected")
    return
end

local file = fs.open("./logs/chat.txt",'a')

local latoModem = peripheral.getName(modem)
rednet.open(latoModem)

local terminal = term.current()
local larg, alt = terminal.getSize() 
local windowChat = window.create(terminal, 1,2, larg, alt-3)
windowChat.setBackgroundColor(colors.white)
windowChat.setTextColor(colors.black)
windowChat.clear()

local windowIn = window.create(terminal,1,alt,larg,1)
windowIn.setBackgroundColor(colors.white)
windowIn.setTextColor(colors.black)
windowIn.clear()

term.setTextColor(colors.white)
term.setCursorPos(1,alt-1)
for i=1,larg do
    write("-")
end
term.setCursorPos(larg-3,1)
term.blit("quit", "ffff", "eeee")



function scrivi(mittente, testo)
    local old = term.redirect(windowChat)
    if testo then
        print(mittente.."> "..testo)
        file.writeLine(mittente.."> "..testo)
    else
        print(mittente)
    end
    term.redirect(old)
end

function ricevi()
    local dist,msg = rednet.receive("chat")
    local t = textutils.unserialise(msg)
    scrivi(t.username, t.msg)
end

function invia()
    local old = term.redirect(windowIn)
    term.setCursorBlink(true)
    testo=read()
    local name = os.computerLabel() or os.computerID()
    local t = {username=name, msg=testo}
    
    rednet.broadcast(textutils.serialise(t),"chat")    
    scrivi(name, testo)
    term.clear()
    
    term.redirect(old)
end

function finisci()
    local event,button, x,y = os.pullEvent("mouse_click")
    if (x>=larg-3 and x<=larg and y==1) then
        run=false
    end
end

local tmp = fs.open("./logs/chat.txt",'r')

repeat
    local msg = tmp.readLine()
    if msg then
        scrivi(msg)
    end
until not msg     

while run do
    parallel.waitForAny(ricevi,invia,finisci)
end

file.close()
term.redirect(terminal)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
rednet.close(latoModem)
