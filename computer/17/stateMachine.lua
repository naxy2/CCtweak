os.loadAPI("tu.lua")
local stato = 1
local path = "data.txt"

function salvaData()
    local file = fs.open("data.txt",'w')
    local data = {
        startPos = tu.startPos,
        stato = stato
    }
    file.write(textutils.serialise(data))
    file.close()
end

function reset()
    tu.vai(tu.startPos)
    stato=2
end
function gira()
    tu.destra(4)
    stato=3
end
function salta()
    tu.su()
    tu.giu()
    stato=4
end
stati = {
    [1] = {f=reset},
    [2] = {f=gira},
    [3] = {f=salta}
}



function main()
    local file
    if fs.exists(path) then
        file = fs.open(path,'r')
        data = textutils.unserialise(file.readAll())
        tu.startPos = data.startPos
        stato = data.stato
        file.close()
    end
    while stato<=#stati do
        stati[stato].f()
        salvaData()
    end
end

main()
