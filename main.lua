aphids = {} 
local aphid = {}
ladybug = {}
bullet = {}
function initLadybug()
    ladybug.spriteShoot = love.graphics.newImage("ladybug2.png")
    ladybug.spriteShoot:setFilter("nearest","nearest")
    ladybug.spriteWalk1 = love.graphics.newImage("ladybug1.png")
    ladybug.spriteWalk1:setFilter("nearest", "nearest")
    ladybug.currentSprite = ladybug.spriteWalk1
    ladybug.rotationDegrees = 0
    ladybug.rotationRadians = 0
    ladybug.x = 100
    ladybug.y = 200
    ladybug.invincible = false
end
function aphidTrackLadyBug(aphidID)

end
function addAphid(aphidX,aphidY)
    local newAphid = {}
    newAphid.x = aphidX
    newAphid.y = aphidY
    newAphid.rot = 0
    newAphid.speed = math.random(50,200)
    table.insert(aphids,newAphid)
end

function aphidsFaceLadyBug(dt)
    for i = 1, #aphids do 

        local deltaX = ladybug.x - aphids[i].x - (8 * 5) --do the getwidth/gethigher later
        local deltaY = ladybug.y - aphids[i].y - (8 * 5)
        local targetAngle = math.atan2(deltaY, deltaX)
        local turnSpeed = 5
        local angleDiff = targetAngle - aphids[i].rot
        while angleDiff > math.pi do angleDiff = angleDiff - 2 * math.pi end
        while angleDiff < -math.pi do angleDiff = angleDiff + 2 * math.pi end
        aphids[i].rot =  aphids[i].rot + angleDiff * turnSpeed * dt --make it so that aphids have collision, ladybug doesnt
    end

end
function CheckCollision(x1,y1,w1,h1,x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end
function aphidsMoveTowardsLadybug(dt)
    for i = 1, #aphids do
        local directionX = ladybug.x + - aphids[i].x
        local directionY = ladybug.y + - aphids[i].y 
        local distance = math.sqrt(directionX^2 + directionY^2)
        if distance > 0 then
            local normalX = directionX / distance 
            local normalY = (directionY / distance) 
    
            aphids[i].x = aphids[i].x + (normalX * aphids[i].speed * dt)
            aphids[i].y = aphids[i].y + (normalY * aphids[i].speed * dt)
        end
    end 
end 
function ladybugCollision()
    
    
    for i = 1, #aphids do 
        if(CheckCollision(ladybug.x,ladybug.y,ladybug.spriteWalk1:getWidth(),ladybug.spriteWalk1:getHeight(),aphids[i].x,aphids[i].y,aphid.sprite:getWidth(),aphid.sprite:getHeight())) then
            --addAphid(100,100)
        end
    end
end
local maxTimeShoot = 0.2
local shootSpriteTimer = 0

function ladybugMovement(dt)
    if love.keyboard.isDown("d") then
        ladybug.x = ladybug.x + (300 * dt)
    end
    if love.keyboard.isDown("a") then
        ladybug.x = ladybug.x - (300 * dt)
    end
    if love.keyboard.isDown("s") then 
        ladybug.y = ladybug.y + (300 * dt)
    end

    if love.keyboard.isDown("w") then 
        ladybug.y = ladybug.y - (300 * dt)
    end

    if love.keyboard.isDown("q") then
        addAphid(math.random(0,800),math.random(0,800))
    end


end

function ladybugRotation(dt)
    local mousex, mousey = love.mouse.getPosition()
    local deltaX = mousex - ladybug.x - ((ladybug.spriteWalk1:getWidth() / 2) * 5)
    local deltaY = mousey - ladybug.y - ((ladybug.spriteWalk1:getHeight() / 2) * 5)
    local targetAngle = math.atan2(deltaY, deltaX)
    local turnSpeed = 10
    local angleDiff = targetAngle - ladybug.rotationRadians
    while angleDiff > math.pi do angleDiff = angleDiff - 2 * math.pi end
    while angleDiff < -math.pi do angleDiff = angleDiff + 2 * math.pi end
    ladybug.rotationRadians = ladybug.rotationRadians + angleDiff * turnSpeed * dt
end

function ladybugShooting(dt)
    if love.keyboard.isDown("space") then
        shootSpriteTimer = maxTimeShoot
    end

    if shootSpriteTimer > 0 then
        ladybug.currentSprite = ladybug.spriteShoot
        shootSpriteTimer = shootSpriteTimer - dt
    else 
        ladybug.currentSprite = ladybug.spriteWalk1
    end
end

function drawAphids()
    for i = 1, #aphids do 
        love.graphics.draw(aphid.sprite, aphids[i].x, aphids[i].y, aphids[i].rot,5, 5,aphid.sprite:getWidth() / 2,aphid.sprite:getHeight() / 2 )
    end
end


function love.load()
    addAphid(200,200)
    addAphid(400,400)
    initLadybug()
    aphid.sprite = love.graphics.newImage("aphid.png") 
    aphid.sprite:setFilter("nearest", "nearest")
    

end


function love.update(dt)
    
    ladybugMovement(dt)
    ladybugRotation(dt)
    ladybugShooting(dt)
    aphidsFaceLadyBug(dt) 
    aphidsMoveTowardsLadybug(dt)
    ladybugCollision()

end

function love.draw()
    love.graphics.print(#aphids,100,100,0,5,5)
    love.graphics.setBackgroundColor(1,1,1)
    drawAphids()
    love.graphics.draw(ladybug.currentSprite,ladybug.x, ladybug.y,ladybug.rotationRadians,5, 5,ladybug.currentSprite:getWidth() / 2,ladybug.currentSprite:getHeight() / 2)
end













