rollout test "Test Timer"
(
    global she_box
    global she_dir = [0,25,0]
    global she_array = #()--蛇身体
    global food =#()
    label she_count ""
    button go_time "Go" --across:2
    button stop "Stop"
    button add_ch "+"
    on go_down pressed do
    (
        she_dir = [0,-25,0]
    )
    button go_up "↑"
    button go_r "←" across:2
    button go_l "→"
    button go_down "↓"

    timer clock "testClock" interval:25 active:false--tick once a second
    label test"1"
    fn new_she_box = --蛇身体
    (
        a = copy she_box--box()
        --a.wirecolor = red
        --a.pos = she_box.pos
        --tem = she_dir *she_dir
        --tem = [abs(she_dir[1])*she_dir[1],abs(she_dir[2])*she_dir[2],abs(she_dir[3])*she_dir[3]] * -1
        --move a tem
        append she_array a
        if she_array.count > 20 do
        (
            delete she_array[1]
            deleteItem she_array 1
        )
    )

    fn she_box_death_border = --检查是否出界
    (
        --she_a = abs(she_box.pos[1])*abs(she_box.pos[2])
        --she_b = life_border.length * life_border.width
        if (abs(she_box.pos[1]) >= 3000) or (abs(she_box.pos[2]) >= 1800 ) do
        --if she_a >= she_b do
        (
            clock.active = false
            she_count.text = "You Death!"
        )
    )
    fn eat = --吃掉
    (
        /*
        a = [12,50,0]
        b = [28,50,0]
        a_x = sqrt (a[1]*a[1] +a[2]*a[2]);b_x = sqrt (b[1]*b[1] +b[2]*b[2])
        b_x - a_x
        5.8 是这么来的
         */
        global she_x = sqrt (she_box.pos[1]*she_box.pos[1] + she_box.pos[2] * she_box.pos[2])
        food_count = food.count
        for i=1 to food_count do
        (try
            (
            tem_food = food[i]
            global food_x = sqrt(tem_food.pos[1]*tem_food.pos[1] + tem_food.pos[2]*tem_food.pos[2])
            if abs(she_x - food_x) <= 5.8 do
            (
                delete tem_food
                deleteItem food i
            )
            )catch()
        )

    )

    fn andom_food = --生成食物
    (
        local new_food = 10 - food.count
        for i=1 to new_food do
        (
            tem_pos = random [-3000,-1800,0]  [3000,1800,0]
            p = box() --食物大小为默认的 25*25
            p.pos = tem_pos
            append food p
        )
    )
    on go_r pressed do
    (
        she_dir = [-25,0,0]
    )
    on go_l pressed do
    (
        she_dir = [25,0,0]
    )
    on go_up pressed do
    (
        she_dir = [0,25,0]
    )
    on go_down pressed do
    (
        she_dir = [0,-25,0]
    )
    on go_time  pressed do
    (
        clock.active = true

        global life_border = box() --活动场
        life_border.length = 3600
        life_border.width = 6000
        life_border.boxmode =true

        she_box = box()
        she_box.length =25
        she_box.width =50
        she_box.wirecolor = red
        she_array = #()

        andom_food()



    )
    on stop pressed do
    (
        clock.active = false
    )
    on clock tick do
    (
        valUp = (test.text as integer)+1
        test.text = valUp as string
        --she_box.pos = [(valUp*1),0,0]
        move she_box she_dir
        new_she_box()
        she_box_death_border()

        eat()
    )
)
createDialog test