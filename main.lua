aphids = {} 
local aphid = {}
ladybug = {}
bullet = {}
local bullets = {}
local dyingAphids = {}
local powerups = {}
local powerup = {}

local health = 3
local maxHealth = 3
local aphidsKilled = 0
local timeElapsed = 0

local invincible = false
local invincibleTimer = 0
local invincibleDuration = 3
local flashTimer = 0
local flashInterval = 0.15
local showLadybug = true


local heartDropChance = 1/40
local fertDropChance = 1/20
local baseFireRate = 0.25
local fireRate = baseFireRate
local fertActive = false
local fertTimer = 0
local fertDuration = 5

local menu = true
local endScreen = false
local score = 0

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

function addAphid(aphidX, aphidY)
    local newAphid = {}
    newAphid.x = aphidX
    newAphid.y = aphidY
    newAphid.rot = 0
    newAphid.speed = math.random(50,200)
    table.insert(aphids, newAphid)
end

function AphidDeath(deadAphid)
    local dying = {
        x = deadAphid.x,
        y = deadAphid.y,
        rot = deadAphid.rot,
        scale = 5,
        shrinkSpeed = 12
    }
    table.insert(dyingAphids, dying)
    aphidsKilled = aphidsKilled + 1

    
    local roll = math.random()
    if roll < heartDropChance and health < maxHealth then
        spawnPowerup(deadAphid.x, deadAphid.y, "heart")
    elseif roll < heartDropChance + fertDropChance then
        spawnPowerup(deadAphid.x, deadAphid.y, "fert")
    end
end

function spawnPowerup(x, y, ptype)
    local p = {x = x,y = y,ptype = ptype,rot = 0}
    table.insert(powerups, p)
end

function updatePowerups(dt)
    for i = #powerups, 1, -1 do
        local p = powerups[i]
        local pw = powerup.heart:getWidth() * 5
        local ph = powerup.heart:getHeight() * 5
        local lw = ladybug.spriteWalk1:getWidth() * 5
        local lh = ladybug.spriteWalk1:getHeight() * 5
        if CheckCollision(p.x - pw/2, p.y - ph/2, pw, ph,ladybug.x - lw/2, ladybug.y - lh/2, lw, lh) then
            if p.ptype == "heart" then
                health = math.min(health + 1, maxHealth)
            elseif p.ptype == "fert" then
                fertActive = true
                fertTimer = fertDuration
                fireRate = baseFireRate / 2
            end
            table.remove(powerups, i)
        end
    end
end

function drawPowerups()
    for i = 1, #powerups do
        local p = powerups[i]
        local sprite = (p.ptype == "heart") and powerup.heart or powerup.fert
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, p.x, p.y, 0, 5, 5,sprite:getWidth() / 2,sprite:getHeight() / 2)
    end
end

function updateDyingAphids(dt)
    for i = #dyingAphids, 1, -1 do
        local d = dyingAphids[i]
        d.scale = d.scale - d.shrinkSpeed * dt
        if d.scale <= 0 then
            table.remove(dyingAphids, i)
        end
    end
end

function drawDyingAphids()
    for i = 1, #dyingAphids do
        local d = dyingAphids[i]
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(aphid.sprite,d.x, d.y,d.rot,d.scale, d.scale,aphid.sprite:getWidth() / 2,aphid.sprite:getHeight() / 2)
    end
end

function aphidsFaceLadyBug(dt)
    for i = 1, #aphids do 
        local deltaX = ladybug.x - aphids[i].x - (8 * 5)
        local deltaY = ladybug.y - aphids[i].y - (8 * 5)
        local targetAngle = math.atan2(deltaY, deltaX)
        local turnSpeed = 5
        local angleDiff = targetAngle - aphids[i].rot
        while angleDiff > math.pi do angleDiff = angleDiff - 2 * math.pi end
        while angleDiff < -math.pi do angleDiff = angleDiff + 2 * math.pi end
        aphids[i].rot = aphids[i].rot + angleDiff * turnSpeed * dt
    end
end 

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and          
           y1 < y2+h2 and
           y2 < y1+h1
end

function aphidsMoveTowardsLadybug(dt)
    for i = 1, #aphids do
        local directionX = ladybug.x - aphids[i].x
        local directionY = ladybug.y - aphids[i].y 
        local distance = math.sqrt(directionX^2 + directionY^2)
        if distance > 0 then
            local normalX = directionX / distance 
            local normalY = directionY / distance
            aphids[i].x = aphids[i].x + (normalX * aphids[i].speed * dt)
            aphids[i].y = aphids[i].y + (normalY * aphids[i].speed * dt)
        end
    end 
end 

function aphidCollision()
    for i = #aphids, 1, -1 do
        local a = aphids[i]
        for j = i + 1, #aphids do
            local b = aphids[j]
            local dx = b.x - a.x
            local dy = b.y - a.y
            local distanceSq = dx * dx + dy * dy
            local radius = 6 * 5
            local minDistance = radius * 2

            if distanceSq < minDistance * minDistance then
                local distance = math.sqrt(distanceSq)
                local overlap = (minDistance - distance) / 2
                local newX, newY = dx / distance, dy / distance
                a.x = a.x - newX * overlap
                a.y = a.y - newY * overlap
                b.x = b.x + newX * overlap
                b.y = b.y + newY * overlap
            end
        end

        for k = #bullets, 1, -1 do
            local b = bullets[k]
            if CheckCollision(a.x, a.y,aphid.sprite:getWidth() * 5,aphid.sprite:getHeight() * 5,b.x, b.y,bullet.sprite:getWidth() * 5,bullet.sprite:getHeight() * 5) then
                AphidDeath(aphids[i])
                table.remove(aphids, i)
                table.remove(bullets, k)
                break
            end
        end
    end
end

function ladybugCollision()
    if invincible then return end

    local lw = ladybug.spriteWalk1:getWidth() * 5
    local lh = ladybug.spriteWalk1:getHeight() * 5

    for i = 1, #aphids do
        local aw = aphid.sprite:getWidth() * 5
        local ah = aphid.sprite:getHeight() * 5
        if CheckCollision(ladybug.x - lw/2, ladybug.y - lh/2, lw, lh,aphids[i].x - aw/2, aphids[i].y - ah/2, aw, ah) then
            health = health - 1
            if health <= 0 then
                endScreen = true
                score = aphidsKilled * math.floor(timeElapsed)
            end
            invincible = true
            invincibleTimer = invincibleDuration
            flashTimer = 0
            showLadybug = true
            break
        end
    end
end

function updateInvincibility(dt)
    if invincible then
        invincibleTimer = invincibleTimer - dt
        flashTimer = flashTimer + dt
        if flashTimer >= flashInterval then
            flashTimer = flashTimer - flashInterval
            showLadybug = not showLadybug
        end
        if invincibleTimer <= 0 then
            invincible = false
            showLadybug = true
        end
    end
end

local shootSpriteTimer = 0

function ladybugMovement(dt)
    if love.keyboard.isDown("d") then ladybug.x = ladybug.x + (300 * dt) end
    if love.keyboard.isDown("a") then ladybug.x = ladybug.x - (300 * dt) end
    if love.keyboard.isDown("s") then ladybug.y = ladybug.y + (300 * dt) end
    if love.keyboard.isDown("w") then ladybug.y = ladybug.y - (300 * dt) end
    if love.keyboard.isDown("q") then
        addAphid(math.random(0,800), math.random(0,800))
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

local shootTimer = 0   
local animationTimer = 0

function ladybugShooting(dt)
    if shootTimer > 0 then shootTimer = shootTimer - dt end
    if animationTimer > 0 then
        animationTimer = animationTimer - dt
        ladybug.currentSprite = ladybug.spriteShoot
    else  
        ladybug.currentSprite = ladybug.spriteWalk1
    end
    if (love.keyboard.isDown("space") or love.mouse.isDown(1)) and shootTimer <= 0 then
        ladybugShoot()
        shootTimer = fireRate        
        animationTimer = 0.1        
    end
end

function updateFert(dt)
    if fertActive then
        fertTimer = fertTimer - dt
        if fertTimer <= 0 then
            fertActive = false
            fireRate = baseFireRate
        end
    end
end

function drawAphids()
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, #aphids do 
        love.graphics.draw(aphid.sprite, aphids[i].x, aphids[i].y,aphids[i].rot, 5, 5,aphid.sprite:getWidth() / 2,aphid.sprite:getHeight() / 2)
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

function drawUI()
    local sw = love.graphics.getWidth()
    local iconScale = 3
    local iconW = ladybug.spriteWalk1:getWidth() * iconScale
    local iconH = ladybug.spriteWalk1:getHeight() * iconScale
    local padding = 8
    local topY = 10


    for i = 1, maxHealth do
        local x = padding + (i - 1) * (iconW + 4)
        if i <= health then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 0.6)
        end
        love.graphics.draw(ladybug.spriteWalk1, x, topY, 0, iconScale, iconScale, 0, 0)
    end

    
    local mins = math.floor(timeElapsed / 60)
    local secs = math.floor(timeElapsed % 60)
    local timeStr = string.format("%02d:%02d", mins, secs)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    local textW = love.graphics.getFont():getWidth(timeStr)
    love.graphics.print(timeStr, sw/2 - textW/2, topY)


    local killStr = ""..aphidsKilled
    local killW = love.graphics.getFont():getWidth(killStr)
    love.graphics.print(killStr, sw - killW - padding, topY)

    
    if fertActive then
        love.graphics.setColor(0.4, 1, 0.4, 1)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print(string.format("%.1fs", fertTimer), padding, topY + iconH + 6)
    end

    love.graphics.setColor(1, 1, 1, 1)
end



function drawBullets()
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, #bullets do
        love.graphics.draw(bullet.sprite, bullets[i].x, bullets[i].y,
            bullets[i].rot, 5, 5,
            bullet.sprite:getWidth()/2, bullet.sprite:getHeight()/2)
    end
end

function drawLadybug()
    if not showLadybug then return end
        love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(ladybug.currentSprite, ladybug.x, ladybug.y,ladybug.rotationRadians, 5, 5,ladybug.currentSprite:getWidth() / 2,ladybug.currentSprite:getHeight() / 2)
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
end
local bobTimer = 0
menuElements = {}
function love.load()
    initLadybug()
    menuElements.evaluation = love.graphics.newImage("Evauation.png")
    menuElements.evaluation:setFilter("nearest", "nearest")
    menuElements.playAgain = love.graphics.newImage("playAgain.png")
    menuElements.playAgain:setFilter("nearest", "nearest")
    aphid.sprite = love.graphics.newImage("aphid.png") 
    aphid.sprite:setFilter("nearest", "nearest")
    bullet.sprite = love.graphics.newImage("bullet.png")
    bullet.sprite:setFilter("nearest", "nearest")
    powerup.heart = love.graphics.newImage("heart.png")
    powerup.heart:setFilter("nearest", "nearest")
    powerup.fert = love.graphics.newImage("fertiliser.png")
    powerup.fert:setFilter("nearest", "nearest")
    menuElements.start = love.graphics.newImage("start.png")
    menuElements.start:setFilter("nearest", "nearest")
    menuElements.title = love.graphics.newImage("title.png")
    menuElements.title:setFilter("nearest", "nearest")
    menuElements.titleX = love.graphics.getWidth()/2 - (69*5)/2 
    menuElements.titleY = 100
    menuElements.startX = love.graphics.getWidth()/2 - (35*4)/2
    menuElements.startY = 400
end


function love.update(dt)
    if menu then
        bobTimer = bobTimer + dt
        if love.mouse.isDown(1) then menu = false end
    end

    if not menu and not endScreen then
        timeElapsed = timeElapsed + dt
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
        updateDyingAphids(dt)
        updateInvincibility(dt)
        updatePowerups(dt)
        updateFert(dt)
    end
end

function drawUIElements()
    love.graphics.setColor(1, 1, 1, 1)
    local bob = math.sin(bobTimer * 2) * 5
    love.graphics.draw(menuElements.title, menuElements.titleX, menuElements.titleY + bob, 0, 5, 5)
    love.graphics.draw(menuElements.start, menuElements.startX, menuElements.startY, 0, 4,4)
end

function reset()
    health = maxHealth
    aphidsKilled = 0
    timeElapsed = 0
    score = 0
    aphids = {}
    bullets = {}
    dyingAphids = {}
    powerups = {}
    spawnTimer = 0
    fertActive = false
    fireRate = baseFireRate
    invincible = false
    showLadybug = true
    ladybug.x = 100
    ladybug.y = 200
    ladybug.rotationRadians = 0
    endScreen = false
end
function drawEndScreen()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local scale = 5

    local letterH = 7
    local letterIndex
    if score >= 2000 then     letterIndex = 0  
    elseif score >= 1500 then letterIndex = 1  
    elseif score >= 1000 then letterIndex = 2  
    elseif score >= 700  then letterIndex = 3  
    elseif score >= 500  then letterIndex = 4  
    else                      letterIndex = 5  
    end
    if love.mouse.isDown(1) then reset() end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(32))
    local label = "GAME OVER"
    love.graphics.print(label, screenWidth/2 - love.graphics.getFont():getWidth(label)/2, screenHeight/2 - 120)


    local quad = love.graphics.newQuad(0, letterIndex * letterH, 6, letterH,
    menuElements.evaluation:getWidth(), menuElements.evaluation:getHeight())
    love.graphics.draw(menuElements.evaluation, quad, screenWidth/2 - (6*scale)/2, screenHeight/2 - 20, 0, scale, scale)

    
    local playAgainWidth = 29 * scale
    local playAgainHeight = 20 * scale
    love.graphics.draw(menuElements.playAgain, screenWidth/2 - playAgainWidth/2, screenHeight/2 + 80, 0, scale, scale)
end
function love.draw()
    love.graphics.setBackgroundColor(55/255, 148/255, 110/255)
    if menu then
        drawUIElements()
    elseif endScreen then
        drawEndScreen()
    else
        drawAphids()
        drawDyingAphids()
        drawBullets()
        drawPowerups()
        drawLadybug()
        drawUI()
    end
end      
