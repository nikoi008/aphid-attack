    aphids = {} 
    local aphid = {}
    ladybug = {}
    bullet = {}
    local bullets = {}
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
            aphids[i].rot =  aphids[i].rot + angleDiff * turnSpeed * dt
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
    function aphidCollision()
        for i = #aphids, 1, -1 do
            local a = aphids[i]
            for j = i + 1, #aphids do 
                local a = aphids[i]
                local b = aphids[j]
                
                
                local dx = b.x - a.x
                local dy = b.y - a.y
                local distanceSq = dx*dx + dy*dy
                local radius = 6 * 5 --todo add scale constant
                local minDistance = radius * 2
                
                if distanceSq < minDistance * minDistance then
                    
                    local distance = math.sqrt(distanceSq)
                    local overlap = (minDistance - distance) / 2
                    
                
                    local newX, newY = dx/distance, dy/distance
                    a.x = a.x - newX * overlap
                    a.y = a.y - newY * overlap
                    b.x = b.x + newX * overlap
                    b.y = b.y + newY * overlap

                end
            end
            for k = #bullets, 1, -1 do
                local b = bullets[k]

                if CheckCollision(
                    a.x, a.y,
                    aphid.sprite:getWidth() * 5,
                    aphid.sprite:getHeight() * 5,
                    b.x, b.y,
                    bullet.sprite:getWidth() * 5,
                    bullet.sprite:getHeight() * 5
                ) then
                    table.remove(aphids, i)
                    table.remove(bullets, k)
                    break 
                end
            end
        end
    end
    function ladybugCollision()
        
        
        for i = 1, #aphids do 
            if(CheckCollision(ladybug.x,ladybug.y,ladybug.spriteWalk1:getWidth(),ladybug.spriteWalk1:getHeight(),aphids[i].x,aphids[i].y,aphid.sprite:getWidth(),aphid.sprite:getHeight())) then
    
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
    local canShoot
    function ladybugShoot()
        local bulletSpeed = 700
        local sideOffset = 25 
        local sideAngle = ladybug.rotationRadians + math.pi/2

        for i = -1, 1, 2 do
            local b = {}
            b.x = ladybug.x + math.cos(sideAngle) * (sideOffset * i)
            b.y = ladybug.y + math.sin(sideAngle) * (sideOffset * i)
            b.dx = math.cos(ladybug.rotationRadians) * bulletSpeed
            b.dy = math.sin(ladybug.rotationRadians) * bulletSpeed
            b.rot = ladybug.rotationRadians + (math.random(1,20) % 4)*90 

            table.insert(bullets, b)
        end
    end

    function updateBullets(dt)
        for i = #bullets, 1, -1 do
            local b = bullets[i]
            b.x = b.x + b.dx * dt
            b.y = b.y + b.dy * dt

            if b.x < -50 or b.x > love.graphics.getWidth() + 50 or 
            b.y < -50 or b.y > love.graphics.getHeight() + 50 then
                table.remove(bullets, i)
            end
        end
    end
    local fireRate = 0.2    
    local shootTimer = 0   
    local animationTimer = 0
    function ladybugShooting(dt)
        if shootTimer > 0 then
            shootTimer = shootTimer - dt
        end
        if animationTimer > 0 then
            animationTimer = animationTimer - dt
            ladybug.currentSprite = ladybug.spriteShoot
        else
            ladybug.currentSprite = ladybug.spriteWalk1
        end

        if (love.keyboard.isDown("space") or love.mouse.isDown(1) )and shootTimer <= 0 then
            ladybugShoot()
            shootTimer = fireRate        
            animationTimer = 0.1        
        end
    end

    function drawAphids()
        for i = 1, #aphids do 
            love.graphics.draw(aphid.sprite, aphids[i].x, aphids[i].y, aphids[i].rot,5, 5,aphid.sprite:getWidth() / 2,aphid.sprite:getHeight() / 2 )
        end
    end
    local spawnTimer = 0
    local difficulty = 1 
    function spawnAphidWave(diff)
        local count = 3 * diff
        local margin = 100 
        
        for i = 1, count do
            local side = math.random(1, 4)
            local spawnX, spawnY
            
            if side == 1 then 
                spawnX = math.random(0, love.graphics.getWidth())
                spawnY = -margin
            elseif side == 2 then 
                spawnX = math.random(0, love.graphics.getWidth())
                spawnY = love.graphics.getHeight() + margin
            elseif side == 3 then 
                spawnX = -margin
                spawnY = math.random(0, love.graphics.getHeight())
            else 
                spawnX = love.graphics.getWidth() + margin
                spawnY = math.random(0, love.graphics.getHeight())
            end
            
            addAphid(spawnX, spawnY)
        end
    end

    function love.load()
        addAphid(200,200)
        addAphid(400,400)
        initLadybug()

        aphid.sprite = love.graphics.newImage("aphid.png") 
        aphid.sprite:setFilter("nearest", "nearest")
        bullet.sprite = love.graphics.newImage("bullet.png")
        bullet.sprite:setFilter("nearest", "nearest")
        

    end


    function love.update(dt)
        
        ladybugMovement(dt)
        ladybugRotation(dt)
        ladybugShooting(dt)
        spawnTimer = spawnTimer + dt
    if spawnTimer >= 1 then
        spawnAphidWave(difficulty)
        spawnTimer = 0

    end
        aphidsFaceLadyBug(dt) 
        aphidsMoveTowardsLadybug(dt)
        ladybugCollision()
        aphidCollision()
        updateBullets(dt)

    end
    function drawBullets()
        for i = 1, #bullets do
            love.graphics.draw(bullet.sprite, bullets[i].x, bullets[i].y, bullets[i].rot, 5, 5, bullet.sprite:getWidth()/2, bullet.sprite:getHeight()/2)
        end
    end

    function drawLadybug()
        love.graphics.draw(ladybug.currentSprite,ladybug.x, ladybug.y,ladybug.rotationRadians,5, 5,ladybug.currentSprite:getWidth() / 2,ladybug.currentSprite:getHeight() / 2)
    end    
    function love.draw()
        love.graphics.setBackgroundColor(55/255,148/255,110/255)
        drawAphids()
        drawBullets()
        drawLadybug()
    end













