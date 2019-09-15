local robot = require("robot")
print("Robot tree farm started")

-- Select the first slot, which is supposed to have a sapling.
robot.select(1)

-- Change these to change the tree farm grid size or the distance between each tree in the grid.
local treesX = 6
local treesZ = 6
local distanceBetweenTrees = 5

-- Goes forward eventually, no matter if something is blocking the path at the moment.
local function GoForward()
	while true do
		local movedSuccessfuly = robot.forward()
		if movedSuccessfuly then
			break
		end
	end
	robot.suck()
end

-- Goes down eventually, no matter if something is blocking the path at the moment.
local function GoDown()
	while true do
		local movedSuccessfuly = robot.down()
		if movedSuccessfuly then
			break
		end
	end
end

-- Checks for a tree
local function CheckForTree()
	-- Check for a block
	if robot.detect() then
		robot.up()
		
		-- Attempt to detect a block above which will determine if the tree has grown.
		local blockFound = robot.detect()
		robot.down()
		
		-- Check tree has grown and if so then go up.
		if blockFound then
			for blocksToMoveUp = 1, 8 do
				-- Destroy the wood in front of the robot
				robot.swing()
				
				-- Check if there is a block above and if so then destroy the block.
				if robot.detectUp() then
					robot.swingUp()
				end
				
				-- Go up
				robot.up()
			end
			
			-- Move back down again
			for blocksToMoveDown = 1, 8 do
				GoDown()
			end
			
			-- Suck up stuff and go forward
			robot.suck()
			robot.suckUp()
			robot.suckDown()
			GoForward()
			
			-- Suck up stuff
			for rotation = 1, 4 do
				robot.turnLeft()
				robot.suck()
			end
			
			-- Go back
			robot.turnAround()
			GoForward()
			robot.turnAround()
			
			-- Place the new sapling here
			robot.place()
		end
	else
		-- There is no block here, place the sapling
		robot.place()
	end
end

-- Scans a row of trees.
local function CheckRowOfTrees()
	-- Check for trees in the X row.
	for treeX = 1, treesX do
		CheckForTree()
		
		-- If this isn't the last tree in the row then move to the next tree in the row.
		if treeX < treesX then
			robot.turnRight()
			for blocksToMove = 1, distanceBetweenTrees do
				GoForward()
			end
			robot.turnLeft()
		end
	end
	
	-- Go back to the first tree in the row.
	robot.turnLeft()
	for blocksToMove = 1, distanceBetweenTrees*(treesX - 1) do
		GoForward()
	end
	robot.turnRight()
end

-- Do the complete cycle.
while true do
	-- Go to each X row in the grid.
	for treeZ = 1, treesZ do
		CheckRowOfTrees()
		
		-- If this isn't the last X row in the grid then go to the next X row in the grid.
		if treeZ < treesZ then
			robot.turnRight()
			GoForward()
			robot.turnLeft()
			for blocksToMove = 1, distanceBetweenTrees do
				GoForward()
			end
			robot.turnLeft()
			GoForward()
			robot.turnRight()
		end
	end
	
	-- Go back to the starting position.
	robot.turnRight()
	GoForward()
	robot.turnRight()
	for blocksToMove = 1, distanceBetweenTrees*(treesZ - 1) do
		GoForward()
		robot.suck()
	end
	robot.turnRight()
	GoForward()
	robot.turnRight()
	
	-- Sleep for five seconds.
	os.sleep(5)
end