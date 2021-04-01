<<<<<<< HEAD
ws, err = http.websocket('ws://wsturtle.herokuapp.com')
if err then
    error(err)
    return err 
end

ws.send('turtle')
while true do
    msg, bo = ws.receive()
    if msg then
        print("ricevuto "..msg)
        if msg == "avanti" then
            turtle.forward()
        end
    end
end
=======
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
>>>>>>> ff8d60540394cc5b4b20ed9948182117749ba660
