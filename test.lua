ws,err = http.websocket("ws://wsturtle.herokuapp.com")
if err then
    print(err)
    return
end

ws.send("turtle")
while true do
    ret, bo = ws.receive()
    if not bo then
        print(ret)
        if (ret=="avanti") then
            turtle.forward()
        end
    else
        print(bo)
    end
end
ws.close()    
