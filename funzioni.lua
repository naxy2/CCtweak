function scavaBox(larghezza, altezza, profondita)
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
-- dispari dispari = in alto a destra
-- pari dispari = in basso a destra
-- dispari pari = in basso a sinistra
-- pari pari = in basso a sinistra
scavaBox(4,2,3)
