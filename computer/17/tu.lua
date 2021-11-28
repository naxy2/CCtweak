startPos = {x=0, y=0, z=0, d=0}
minerali = {
    "minecraft:coal_ore",
    "minecraft:deepslate_coal_ore",
    "minecraft:iron_ore",
    "minecraft:deepslate_coal_ore",
    "minecraft:copper_ore",
    "minecraft:deepslate_copper_ore",
    "minecraft:gold_ore",
    "minecraft:deepslate_gold_ore",
    "minecraft:redstone_ore",
    "minecraft:deepslate_redstone_ore",
    "minecraft:emerald_ore",
    "minecraft:deepslate_emerald_ore",
    "minecraft:lapis_ore",
    "minecraft:deepslate_lapis_ore",
    "minecraft:diamond_ore",
    "minecraft:deepslate_diamond_ore",
    "minecraft:nether_gold_ore",
    "minecraft:nether_quarts_ore"
}

local function isInLista(lista, elemento, funzione)
    local i=0
    repeat
        i=i+1
    until i>#lista or ((not funzione and elemento==lista[i]) or (funzione and funzione(lista[i],elemento)) )
    return i<=#lista
end

function isMinerale(nome)
    return isInLista(minerali,nome)
end


function curPos()
    return {x=startPos.x, y=startPos.y, z=startPos.z, d=startPos.d}
end
function newPos()
    return {x=0, y=0, z=0, d=0}
end
function facingPos()
    local tmp = curPos()
    if     tmp.d == 0 then tmp.x = tmp.x+1 
    elseif tmp.d == 1 then tmp.y = tmp.y+1
    elseif tmp.d == 2 then tmp.x = tmp.x-1
    elseif tmp.d == 3 then tmp.y = tmp.y-1
    end
    return tmp
end
function upPos()
    local tmp = curPos()
    tmp.z = tmp.z-1
    return tmp
end
function downPos()
    local tmp = curPos()
    tmp.z = tmp.z+1
    return tmp
end


function findSlot(nome)
    local oldSlot = turtle.getSelectedSlot()
    local i=0
    local item
    repeat
        i=i+1
        turtle.select(i)
        item = turtle.getItemDetail()
    until i>=17 or (item and item.name==nome)
    turtle.select(oldSlot)
    return i 
end

function dist(p, p2)
    if not p2 then p2=newPos() end
    return math.abs(p2.x-p.x) + math.abs(p2.y-p.y) + math.abs(p2.z-p.z)
end

function guarda(direzione)
    if direzione == startPos.d then
    elseif math.abs(startPos.d - direzione) == 2 then
        sinistra()
        sinistra()
    elseif (direzione<startPos.d or (startPos.d==0 and direzione==3)) and not (startPos.d==3 and direzione==0) then
        sinistra()
    elseif direzione>startPos.d or (startPos.d==3 and direzione==0)then
        destra()
    end
end

function vai(pos)
    pos = {x=startPos.x-pos.x, y=startPos.y-pos.y, z=startPos.z-pos.z, d=pos.d}
    ritorna(pos)
    guarda(pos.d)
end
function ritorna(pos)
    if not pos then pos=startPos end
    local d = pos.d
    --allinea X
    if pos.x > 0 then
        guarda(2)
        avanti(pos.x, pos==startPos)
    elseif pos.x < 0 then
        guarda(0)
        avanti(-pos.x, pos==startPos)
    end
    --allinea Y
    if pos.y > 0 then
        guarda(3)
        avanti(pos.y, pos==startPos)
    elseif pos.y < 0 then
        guarda(1)
        avanti(-pos.y, pos==startPos)
    end

    --allinea Z
    if pos.z > 0 then
        su(pos.z, pos==startPos)
    elseif pos.z < 0 then
        giu(-pos.z, pos==startPos)
    end
    if pos==startPos then
        guarda(0)
    else
        guarda(pos.d)
    end
end

local function refuel()
    local oldSlot = turtle.getSelectedSlot()
    local trovatoFuel=false
    for i=1,16 do
        turtle.select(i)
        if turtle.refuel() then trovatoFuel=true end
    end
    turtle.select(oldSlot)
    if trovatoFuel then return end
    local puntoInterruzione = curPos()
    ritorna(startPos)
    --chiedifuel
    term.clear()
    term.setCursorPos(1,1)
    print("waiting for fuel...")
    while turtle.getFuelLevel() <= dist(puntoInterruzione)*2+2 do
        os.pullEvent("turtle_inventory")
        for i=1,16 do
            turtle.select(i)
            turtle.refuel()
        end
    end
    turtle.select(oldSlot)
    ritorna({x=-puntoInterruzione.x, y=-puntoInterruzione.y, z=-puntoInterruzione.z, d=0})
    --for i=1,puntoInterruzione.d do destra() end
    guarda(puntoInterruzione.d)
end

function isPieno()
    return turtle.getItemSpace(16) < 64
end
function svuotaInventario()
    local oldSlot = turtle.getSelectedSlot()
    for i=2,16 do
        turtle.select(i)
        for j=1,i-1 do
            if turtle.getItemCount()>0 then
                turtle.transferTo(j)
            end
        end
    end
    if not isPieno() then
        turtle.select(oldSlot)
        return
    end

    local interruzione = curPos()
    ritorna(startPos)
    guarda(2)
    local svuotato = true
    for i=1,16 do
        turtle.select(i)
        if turtle.getItemCount()>0 then
            svuotato = svuotato and turtle.drop()
        end
    end
    if not svuotato then
        repeat
            os.pullEvent("turtle_inventory")
            local svuotato = true
            for i=1,16 do
                turtle.select(i)
                if turtle.getItemCount()>0 then
                    svuotato = svuotato and turtle.drop()
                end
            end
        until svuotato
    end

    turtle.select(oldSlot)
    vai(interruzione)
end

local function muovi(movimento,scavo,isRitorno)
    if not isRitorno and dist(startPos) >= turtle.getFuelLevel()-1 then refuel() end
    if not isRitorno and isPieno() then svuotaInventario() end
    while not movimento() do
        scavo()
    end
end
function avanti(n, isRitorno)
    n=n or 1
    for i=1,n do
        muovi(turtle.forward,turtle.dig, isRitorno)
        if     startPos.d == 0 then startPos.x=startPos.x+1
        elseif startPos.d == 1 then startPos.y=startPos.y+1 
        elseif startPos.d == 2 then startPos.x=startPos.x-1 
        elseif startPos.d == 3 then startPos.y=startPos.y-1
        end
    end
end
function su(n, isRitorno)
    n=n or 1
    for i=1,n do
        muovi(turtle.up,turtle.digUp, isRitorno)
        startPos.z = startPos.z-1
    end
end
function giu(n, isRitorno)
    n=n or 1
    for i=1,n do
        muovi(turtle.down,turtle.digDown, isRitorno)
        startPos.z = startPos.z+1
    end
end
function sinistra(n)
    for i=1,n or 1 do turtle.turnLeft() startPos.d = (startPos.d+3)%4 end
end
function destra(n)
    for i=1,n or 1 do turtle.turnRight() startPos.d = (startPos.d+1)%4 end
end


local function areEqualPos(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

function scavaMateriale(nome)
    if not nome then nome = ({turtle.inspect()})[2].name end
    local inizio = curPos()
    local posizioni = {}
    repeat  
        if #posizioni > 0 then
            local c = curPos()
            table.sort(posizioni, function(a,b) return dist(c,a)>dist(c,b) end)
            local d = table.remove(posizioni)
            vai(d)
        end
        local up = turtle.inspectUp()
        if up and ({turtle.inspectUp()})[2].name == nome then
            if not isInLista(posizioni, upPos(), areEqualPos) then table.insert(posizioni, upPos()) end
        end

        local down = turtle.inspectDown()
        if down and ({turtle.inspectDown()})[2].name == nome then
            if not isInLista(posizioni, downPos(), areEqualPos) then table.insert(posizioni, downPos()) end
        end

        local tmpD = curPos().d
        for i=0, 3 do
            guarda((tmpD+i)%4)
            local front = turtle.inspect()
            if front and ({turtle.inspect()})[2].name == nome then
                if not isInLista(posizioni, facingPos(), areEqualPos) then table.insert(posizioni, facingPos()) end
            end
        end
    until #posizioni == 0
    vai(inizio)
end
function scava()
    local inizio = curPos()
    local posizioni = {}
    repeat  
        if #posizioni > 0 then
            local c = curPos()
            table.sort(posizioni, function(a,b) return dist(c,a)>dist(c,b) end)
            local d = table.remove(posizioni)
            vai(d)
        end
        local up = turtle.inspectUp()
        if up and isMinerale(({turtle.inspectUp()})[2].name) then
            if not isInLista(posizioni, upPos(), areEqualPos) then table.insert(posizioni, upPos()) end
        end

        local down = turtle.inspectDown()
        if down and isMinerale(({turtle.inspectDown()})[2].name) then
            if not isInLista(posizioni, downPos(), areEqualPos) then table.insert(posizioni, downPos()) end
        end

        local tmpD = curPos().d
        for i=0, 3 do
            guarda((tmpD+i)%4)
            local front = turtle.inspect()
            if front and isMinerale(({turtle.inspect()})[2].name) then
                if not isInLista(posizioni, facingPos(), areEqualPos) then table.insert(posizioni, facingPos()) end
            end
        end
    until #posizioni == 0
    vai(inizio)
end
