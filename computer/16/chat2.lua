local modems = {peripheral.find("modem")}

if #modems == 0 then
    error("No modem found")
    return
end

if not term.isColor() then
    error("No touchscreen")
    return
end

local modem = modems[1]
table.foreach(modems, function(i,m)
    if m.isWireless() then modem=m end
end)

local latoModem=peripheral.getName(modem)
local eraAperto = rednet.isOpen(latoModem)
rednet.open(latoModem)

local calnale
local partecipanti = {}
local terminale = term.current()
local larg,alt = terminale.getSize()

local finestre={}
local running=true

local username = os.computerLabel() or os.computerID()

fs.makeDir("chats")

local menu = window.create(terminale,1,1, larg,alt)
table.insert(finestre, menu)
menu.setBackgroundColor(colors.blue)
menu.clear()
menu.setBackgroundColor(colors.gray)
menu.setTextColor(colors.yellow)
--menu.setCursorPos(larg/2-8,alt/2-1)
--menu.write(" select channel ")
menu.setCursorPos(larg/2-7,alt/2)
menu.write(" open channel ")
menu.setBackgroundColor(colors.red)
menu.setTextColor(colors.white)
menu.setCursorPos(larg/2-3, alt/2+2)
menu.write(" quit ")

local paginaCreazioneCanale = window.create(terminale, 1,1, larg,alt)
table.insert(finestre, paginaCreazioneCanale)
paginaCreazioneCanale.setBackgroundColor(colors.blue)
paginaCreazioneCanale.clear()
paginaCreazioneCanale.setBackgroundColor(colors.gray)
paginaCreazioneCanale.setTextColor(colors.yellow)
paginaCreazioneCanale.setCursorPos(1,1)
paginaCreazioneCanale.blit("menu","4444","7777")

local mainFinestraChat = window.create(terminale,1,1,larg,alt)
table.insert(finestre, mainFInestraChat)
mainFinestraChat.setBackgroundColor(colors.gray)
mainFinestraChat.setTextColor(colors.white)
mainFinestraChat.clear()
mainFinestraChat.setCursorPos(1,alt-1)
for i=1,larg-15 do
    mainFinestraChat.write("-")
end
mainFinestraChat.write("o")
for i=1,14 do
    mainFinestraChat.write("-")
end
for i=2,alt-2 do
    mainFinestraChat.setCursorPos(larg-14,i)
    mainFinestraChat.write("|")
end
mainFinestraChat.setCursorPos(1,1)
mainFinestraChat.blit("menu", "4444", "7777")
mainFinestraChat.setCursorPos(larg-3,1)
mainFinestraChat.blit("quit", "ffff", "eeee")

local subChat = window.create(mainFinestraChat, 1,2, larg-15,alt-3)
subChat.setBackgroundColor(colors.white)
subChat.setTextColor(colors.black)
subChat.clear()
local subIn = window.create(mainFinestraChat,1,alt,larg,1)
subIn.setBackgroundColor(colors.white)
subIn.clear()
subIn.setTextColor(colors.black)
local subChan = window.create(mainFinestraChat,larg-13,2, 14,alt-3)
subChan.setBackgroundColor(colors.white)
subChan.setTextColor(colors.black)
subChan.clear()

function nascondiFinestre(listaFinestre)
    if not listaFinestre then listaFinestre = finestre end
    table.foreach(listaFinestre, function(indice, finestra)
        finestra.setVisible(false)
    end)
end

function esci()
    term.redirect(terminale)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    for i=1,alt do
        term.scroll(1)
        sleep(0.001)
    end
    term.setCursorPos(1,1)
    running=false
end

local file
function scriviMsg(user, msg)
    term.redirect(subChat)
    print(user.."> "..msg)
    file.writeLine(user.."> "..msg)
    term.redirect(terminale)
end

function invia(messaggio)
    rednet.broadcast(textutils.serialise({
        tipo = "msg",
        msg = messaggio,
        nick = username
    }), "chat-"..canale)

    scriviMsg(username,messaggio)
end

function aggiornaListaMembri()
    subChan.setCursorPos(1,1)
    term.redirect(subChan)
    term.clear()
    table.sort(partecipanti)
    table.foreach(partecipanti, function(i,v) print(v) end)
    term.redirect(terminale)
end

function mostraMenu()end
function joinaCanale()
    subChat.clear()
    subChat.setCursorPos(1,1)
    if fs.exists("./chats/"..canale..".txt") then
        local txt
        file = fs.open("./chats/"..canale..".txt", 'r')
        term.redirect(subChat)
        local riga
        repeat
            riga = file.readLine()
            if riga then
                print(riga)
            end
        until not riga
        term.redirect(terminale)
        file.close()
    end
    file = fs.open("./chats/"..canale..".txt", 'a')


    subChan.clear()
    rednet.broadcast(textutils.serialise({
        tipo="update",
        nick=username,
        azione="arrivo",
        id=os.computerID()
    }), "chat-"..canale)

    partecipanti = {tostring(username)}
    aggiornaListaMembri()

    nascondiFinestre()
    mainFinestraChat.setVisible(true)
    mainFinestraChat.redraw()
    term.setCursorPos(larg/2-#canale/2,1)
    write(canale)
    local quittare=false
    local menuare=false
    local terminare=false
    
    function tmp1()
        term.redirect(subIn)
        local testo
        repeat
            term.setCursorPos(1,1)
            testo=read()
        until testo ~= ""
        term.clear()
        term.redirect(terminale)
        invia(testo)
    end
    function tmp2()
        local e,b,x,y = os.pullEvent("mouse_click")
        if y==1 then
            if x>=1 and x<=4 then
                menuare=true
            end
            if x>=larg-3 or x<=larg then
                quittare=true
            end
        end
    end
    function tmp3()
        local dist,msg = rednet.receive("chat-"..canale)
        local ricevuto = textutils.unserialise(msg)
        if ricevuto.tipo == "msg" then
            scriviMsg(ricevuto.nick, ricevuto.msg)
        elseif ricevuto.tipo == "update" then  
            if ricevuto.azione == "arrivo" then
                table.insert(partecipanti, tostring(ricevuto.nick))
                rednet.send(ricevuto.id, textutils.serialise({tipo="update", azione="aggiornamento", nick=username}), "chat-"..canale)
            elseif ricevuto.azione == "abbandono" then
                table.foreach(partecipanti, function(i,v) if v==tostring(ricevuto.nick) then table.remove(partecipanti,i) end end)
            elseif ricevuto.azione == "aggiornamento" then
                table.insert(partecipanti, tostring(ricevuto.nick))
            end
            aggiornaListaMembri()
        end
    end
    function tmp4()
        if os.pullEventRaw("terminate") then 
            terminare = true
            rednet.broadcast(textutils.serialise({
                tipo="update",
                azione="abbandono",
                nick=username
            }), "chat-"..canale)
        end
    end

    while quittare==false and menuare==false and terminare==false do
        parallel.waitForAny(tmp1, tmp2, tmp3, tmp4)
    end
    term.redirect(terminale)

    rednet.broadcast(textutils.serialise({
        tipo="update",
        azione="abbandono",
        nick=username
    }), "chat-"..canale)
    file.close()
    if menuare then mostraMenu() end
    if quittare or terminare then esci() end
end



local lastInput
local premuto
function leggiInput()
   repeat 
       lastInput=read()
       if lastInput=="" then
            term.setCursorPos(17,alt/2)
       end
   until lastInput ~= ""     
end
function aspettaMenu()
    premuto=false
    repeat 
        local a,b,x,y = os.pullEvent("mouse_click")
    until y==1 and x>=1 and x<=4
    premuto=true
end
function creaCanale()
    nascondiFinestre()
    paginaCreazioneCanale.setVisible(true)
    paginaCreazioneCanale.redraw()
    term.setCursorPos(2,alt/2)
    term.setBackgroundColor(colors.gray)
    write(" Channel name: ")
    parallel.waitForAny(leggiInput,aspettaMenu)
    if premuto then
        mostraMenu()
    else
        canale=lastInput
        joinaCanale()
    end
end

function mostraMenu()
    nascondiFinestre()
    menu.setVisible(true)
    menu.redraw()
    local ritorna,apri,quit
    local str
    if canale then
        str=" return to "..canale.." "
        term.setCursorPos(larg/2-#str/2,alt/2-1)
        term.setTextColor(colors.yellow)
        term.write(" return to "..canale.." ")
    end
    repeat    
        local event,bottone, x,y = os.pullEvent("mouse_click")
        ritorna = canale and y==math.floor(alt/2-1) and x>=larg/2-#str/2 and x<=larg/2+#str/2
        apri = y==math.floor(alt/2) and x>=larg/2-7 and x<=larg/2+6
        quit = y==math.floor(alt/2+2) and x>=larg/2-3 and x<=larg/2+2
        --print(x,y," ",alt/2+2,larg/2-3,larg/2+2)
    until ritorna or apri or quit
    if quit then esci() end
    if apri then creaCanale() end
    if ritorna then joinaCanale() end
end

mostraMenu()

if not eraAperto then
    rednet.close(latoModem)
end
fs.delete("chats/")