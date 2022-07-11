-- -----------------------------------------------------
-- This is where we store the data for all levels
-- -----------------------------------------------------
-- FORMAT:
-- There are 6 kinds of bricks from 1 - 6
-- Use "-" to denote a metal (unbreakable) brick
-- 0 (zero) represents empty space
-- -----------------------------------------------------
-- Currently we can't specify where pills are stored
-- It's just random. Might want to change that


-- Store Data for All Levels in levels object
levels = {}

-- Level 1
levels[1] = {}
levels[1][1] = { 0, 2,   2, 4, 1, 1,   1, 1, 1, 0 }
levels[1][2] = { 0, 1,   0, 0, 0, 0,   0, 0, 1 }
levels[1][3] = { 0, 2,   2, 4, 5, 6,   1, 4, 4 }
levels[1][4] = { 0, 2,   3, 4, 5, 6,   1, 1, 1 }
levels[1][5] = { 0, 1,   0, 0, 0, 1,   0, 0, 1 }
levels[1][6] = { 0, 1,   1, 1, 1, 1,   1, 1, 1 }
levels[1][7] = { 0, 2,   3, 4, 5, 1,   0, 0, 1 }
levels[1][8] = { 0, 1,   0, 0, 0, 1,   0, 0, 1 }
levels[1][9] = { 0, 1,   1, 1, 1, 1,   1, 1, 1 }
levels[1][10]= { 0, 2, "-", 4, 5, 1, "-", 1, 1 }

-- Level 2
levels[2] = {}
levels[2][1] = { 1, 2, 3, 4, 1, 1, 1, 1, 1 }
levels[2][2] = { 1, 1, 0, 0, 0, 1, 1, 1, 1 }
levels[2][3] = { 1, 2, 3, 4, 5, 6, 6, 4, 4 }
levels[2][4] = { 1, 2, 3, 4, 5, 6, 6, 1, 1 }
levels[2][5] = { 1, 1, 0, 0, 0, 1, 1, 0, 0 }
levels[2][6] = { 1, 1, 1, 1, 1, 1, 1, 1, 1 }
levels[2][7] = { 1, 2, 3, 4, 5, 1, 1, 0, 0 }
levels[2][8] = { 1, 1, 0, 0, 0, 1, 1, 0, 0 }
levels[2][9] = { 1, 1, 1, 1, 1, 1, 1, 0, 0 }
levels[2][10]= { 1, 2, 3, 4, 5, 1, 1, 1, 1 }

-- Level 3
levels[3] = {}
levels[3][1] = { 0, 0, 3, 4, 1, 1, 1, 1, 1, 1 }
levels[3][2] = { 0, 0, 0, 0, 0, 1, 1, 1, 1 }
levels[3][3] = { 0, "-", 3, 4, 5, 6, 6, 4, 4 }
levels[3][4] = { 0, "-", 3, 4, 5, 6, 6, 1, 1 }
levels[3][5] = { 0, "-", 0, 0, 0, 1, 1, 0, 0 }
levels[3][6] = { 0, "-", 1, 1, 1, 1, 1, 1, 1 }
levels[3][7] = { 0, "-", 1, 1, 1, 1, 1, 1, 1 }
levels[3][8] = { 0, "-", 1, 1, 1, 1, 1, 1, 1 }
levels[3][9] = { 0, "-", 1, 1, 1, 1, 1, 1, 1 }
levels[3][10]= { 0, "-","-", "-", "-", "-", "-", "-", "-", "-" }