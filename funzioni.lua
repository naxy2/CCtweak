function muovi(movimento, scavo)
<<<<<<< HEAD
    repeat 
        scavo()
    until movimento()
end
function avanza() muovi(turtle.forward,turtle.dig) end
function sali() muovi(turtle.up,turtle.digUp) end
function scendi() muovi(turtle.down,turtle.digDown) end
=======
    do 
        scavo()
    until movimento()
end
function avanza(muovi(turtle.forward,turtle.dig) end
function sali(muovi(turtle.up,turtle.digUp) end
function scendi(muovi(turtle.down,turtle.digDown) end
>>>>>>> ff8d60540394cc5b4b20ed9948182117749ba660

function scavaBox(larghezza, altezza, profondita)
    posizione = vecotr.new(0,0,0)

    for alt = 1,altezza do
        for larg = 1,larghezza do
            for prof = 1,profondita-1 do
                turtle.dig()
                turtle.forward()
            end
            if not (larg == larghezza) then
                --if larg%2 == ( (larghezza%2==0 and alt%2==0) and 0 or 1 ) then
                if bit.band(larg,1) == ( (bit.band(larghezza,1)+bit.band(alt,1)==0) and 0 or 1 ) then
                    turtle.turnRight()
                    turtle.dig()
                    turtle.forward()
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                    turtle.dig()
                    turtle.forward()
                    turtle.turnLeft()
                end
            end
        end
        if not (alt == altezza) then
            turtle.digDown()
            turtle.down()
        end
        turtle.turnLeft()
        turtle.turnLeft()
    end
    if (altezza%2==1) then
        if (larghezza%2==1) then
            for prof = 1,profondita-1 do
                turtle.forward()
            end
            turtle.turnLeft()
            turtle.turnLeft()
        end
        turtle.turnLeft()
        for larg = 1,larghezza-1 do
            turtle.forward()
        end
        turtle.turnRight()
    end
    for alt = 1,altezza-1 do
        turtle.digUp()
        turtle.up()
    end
end
