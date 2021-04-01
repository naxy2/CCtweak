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
