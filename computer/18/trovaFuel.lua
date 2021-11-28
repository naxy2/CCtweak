os.loadAPI("tu.lua")

turtle.dig()
turtle.craft()
turtle.transferTo(5,2)
turtle.craft()
turtle.refuel()
turtle.forward()
repeat
    turtle.digUp()
    turtle.up()
until not turtle.compareUp()
repeat 
    turtle.down()
until turtle.detectDown()

turtle.craft()
turtle.transferTo(5, turtle.getItemCount()/2)
turtle.craft()
turtle.refuel()
