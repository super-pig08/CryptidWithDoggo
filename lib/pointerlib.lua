-- god the jank
Cryptid.pointerblist = {}
Cryptid.pointerblisttype = {}
Cryptid.pointeralias = {}



function Cryptid.pointerblistify(target, remove) -- Add specific joker to blacklist, must input either a card object or a key as string, eg: 
    if not Cryptid.pointerblist then Cryptid.pointerblist = {} end
    if not remove then
        Cryptid.pointerblist[#Cryptid.pointerblist + 1] = target
        return true
    else
        for i = 1, #Cryptid.pointerblist do
            if Cryptid.pointerblist[i] == target then
                table.remove(Cryptid.pointerblisttype, i)
            end
        end
    end
end

function Cryptid.pointeraliasify(target, key, remove)
	print(key)
	if string.len(key) ~= 1 then
		key = string.lower(key:gsub("%b{}", ""):gsub("%s+", ""))
	end
	print(key)
    if not remove then
		if not Cryptid.pointeralias[target] then Cryptid.pointeralias[target] = {} end
        Cryptid.pointeralias[target][#Cryptid.pointeralias[target] + 1] = key
		print(#Cryptid.pointeralias[target])
		print(#Cryptid.pointeralias)
		return true
    else 
        for v = 1, #Cryptid.pointeralias[target] do
            if Cryptid.pointeralias[target][v] == key then
                table.remove(Cryptid.pointeralias, v)
				return true
            end
        end
    end
end

function Cryptid.pointerblistifytype(target, key, remove) -- eg: (rarity, "cry-exotic", nil)
    if not Cryptid.pointerblisttype then Cryptid.pointerblisttype = {} end
    if not Cryptid.pointerblisttype[target] then Cryptid.pointerblisttype[target] = {} end
    if not remove then
        Cryptid.pointerblisttype[target][#Cryptid.pointerblisttype[target] + 1] = key
        return true
    else
        for v = 1, #Cryptid.pointerblisttype[target] do
            if Cryptid.pointerblisttype[target][v] == key then
                table.remove(Cryptid.pointerblisttype, v)
                return true
            end
        end
    end
end

function Cryptid.pointergetalias(target) 
	target = tostring(target)
	-- print(#Cryptid.pointeralias)
    for card, _ in pairs(Cryptid.pointeralias) do
        if card == target then return card end
        for _, alias in ipairs(Cryptid.pointeralias[card]) do
            if alias == target then return card end
        end
    end
    return false
end

function Cryptid.pointergetblist(target) -- "Is this card pointer banned?"
    target = Cryptid.pointergetalias(target)
    if G.GAME.banned_keys[target] then return true end
    for index, value in ipairs(Cryptid.pointerblist) do
        if target == value then return true end
    end
    for index, value in ipairs(Cryptid.pointerblisttype) do
        if target.value --[[ this wont work ]] then
            for index2, value2 in ipairs(Cryptid.pointerblisttype[index]) do
                if target.value == value2 then return true end
            end
        end
    end
    return false
end


local aliases = {
        -- Vanilla Jokers
        jolly = "jolly joker",
        zany = "zany joker",
        mad = "mad joker",
        crazy = "crazy joker",
        droll = "droll joker",
        sly = "sly joker",
        wily = "wily joker",
        clever = "clever joker",
        devious = "devious joker",
        crafty = "crafty joker",
        half = "half joker",
        stencil = "joker stencil",
        dagger = "ceremonial dagger",
        chaos = "chaos the clown",
        fib = "fibonacci",
        scary = "scary face",
        abstract = "abstract joker",
        delayedgrat = "delayed gratification",
        banana = "gros michel",
        steven = "even steven",
        todd = "odd todd",
        bus = "ride the bus",
        faceless = "faceless joker",
        todo = "to do list",
        ["to-do"] = "to do list",
        square = "square joker",
        seance = "séance",
        riffraff = "riff-raff",
        cloudnine = "cloud 9",
        trousers = "spare trousers",
        ancient = "ancient joker",
        mrbones = "mr. bones",
        smeared = "smeared joker",
        wee = "wee joker",
        oopsall6s = "oops! all 6s",
        all6s = "oops! all 6s",
        oa6 = "oops! all 6s",
        idol = "the idol",
        duo = "the duo",
        trio = "the trio",
        family = "the family",
        order = "the order",
        tribe = "the tribe",
        invisible = "invisible joker",
        driverslicense = "driver's license",
        burnt = "burnt joker",
        caino = "canio",
        -- Cryptid Jokers
        house = "happy house",
        queensgambit = "queen's gambit",
        weefib = "weebonacci",
        interest = "compound interest",
        whip = "the whip",
        triplet = "triplet rhythm",
        pepper = "chili pepper",
        krusty = "krusty the clown",
        blurred = "blurred joker",
        gofp = "garden of forking paths",
        lutn = "light up the night",
        nsnm = "no sound, no memory",
        nosoundnomemory = "no sound, no memory",
        lath = "...like antennas to heaven",
        likeantennastoheaven = "...like antennas to heaven",
        consumeable = "consume-able",
        error = "j_cry_error",
        ap = "ap joker",
        rng = "rnjoker",
        filler = "the filler",
        duos = "the duos",
        home = "the home",
        nuts = "the nuts",
        quintet = "the quintet",
        unity = "the unity",
        swarm = "the swarm",
        crypto = "crypto coin",
        googol = "googol play card",
        googolplay = "googol play card",
        google = "googol play card",
        googleplay = "googol play card",
        googleplaycard = "googol play card",
        nostalgicgoogol = "nostalgic googol play card",
        nostalgicgoogolplay = "nostalgic googol play card",
        nostalgicgoogle = "nostalgic googol play card",
        nostalgicgoogleplay = "nostalgic googol play card",
        nostalgicgoogleplaycard = "nostalgic googol play card",
        oldgoogol = "nostalgic googol play card",
        oldgoogolplay = "nostalgic googol play card",
        oldgoogle = "nostalgic googol play card",
        oldgoogleplay = "nostalgic googol play card",
        oldgoogleplaycard = "nostalgic googol play card",
        ngpc = "nostalgic googol play card",
        localthunk = "supercell",
        ["1fa"] = "one for all",
        ["jolly?"] = "jolly joker?",
        scrabble = "scrabble tile",
        oldcandy = "nostalgic candy",
        jimbo9000 = "jimbo-tron 9000",
        jimbotron9000 = "jimbo-tron 9000",
        magnet = "fridge magnet",
        weeb = "weebonacci",
        potofgreed = "pot of jokes",
        flipside = "on the flip side",
        bonkers = "bonkers joker",
        fuckedup = "fucked-up joker",
        foolhardy = "foolhardy joker",
        adroit = "adroit joker",
        penetrating = "penetrating joker",
        treacherous = "treacherous joker",
        stronghold = "the stronghold",
        thefuck = "the fuck!?",
        ["tf!?"] = "the fuck!?",
        wtf = "the fuck!?",
        clash = "the clash",
        astral = "astral in a bottle",
        smoothie = "tropical smoothie",
        chocodie = "chocolate die",
        chocodice = "chocolate die",
        chocolatedice = "chocolate die",
        cookie = "clicked cookie",
        lebronjames = "lebaron james",
        lebron = "lebaron james",
        lebaron = "lebaron james",
        hunting = "hunting season",
        clockwork = "clockwork joker",
        monopoly = "monopoly money",
        notebook = "the motebook",
        motebook = "the motebook",
        mcdonalds = "fast food m",
        code = "code joker",
        copypaste = "copy/paste",
        translucent = "translucent joker",
        circulus = "circulus pistoris",
        macabre = "macabre joker",
        cat_owl = "cat owl",
        --Vouchers
        ["overstock+"] = "overstock plus",
        directorscut = "director's cut",
        ["3rs"] = "the 3 rs",
        -- Vanilla Tarots
        fool = "the fool",
        magician = "the magician",
        priestess = "the high priestess",
        highpriestess = "the high priestess",
        empress = "the empress",
        emperor = "the emperor",
        hierophant = "the hierophant",
        lovers = "the lovers",
        chariot = "the chariot",
        hermit = "the hermit",
        wheeloffortune = "the wheel of fortune",
        hangedman = "the hanged man",
        devil = "the devil",
        tower = "the tower",
        star = "the star",
        moon = "the moon",
        sun = "the sun",
        world = "the world",
        -- Cryptid Tarots
        automaton = "the automaton",
        eclipse = "c_cry_eclipse",
        -- Planets
        x = "planet x",
        X = "planet x",
        -- Code Cards
        pointer = "pointer://",
        payload = "://payload",
        reboot = "://reboot",
        revert = "://revert",
        crash = "://crash",
        semicolon = ";//",
        [";"] = ";//",
        malware = "://malware",
        seed = "://seed",
        variable = "://variable",
        class = "://class",
        commit = "://commit",
        merge = "://merge",
        multiply = "://multiply",
        divide = "://divide",
        delete = "://delete",
        machinecode = "://machinecode",
        run = "://run",
        exploit = "://exploit",
        offbyone = "://offbyone",
        rework = "://rework",
        patch = "://patch",
        ctrlv = "://ctrl+v",
        ["ctrl+v"] = "://ctrl+v",
        ["ctrl v"] = "://ctrl+v",
        hook = "hook://",
        instantiate = "://INSTANTIATE",
        inst = "://INSTANTIATE",
        spaghetti = "://spaghetti",
        alttab = "://alttab",
        -- Tags
        topuptag = "top-up tag",
        gamblerstag = "gambler's tag",
        -- Blinds
        ox = "the ox",
        wall = "the wall",
        wheel = "the wheel",
        arm = "the arm",
        club = "the club",
        fish = "the fish",
        psychic = "the psychic",
        goad = "the goad",
        water = "the water",
        window = "the window",
        manacle = "the manacle",
        eye = "the eye",
        mouth = "the mouth",
        plant = "the plant",
        serpent = "the serpent",
        pillar = "the pillar",
        needle = "the needle",
        head = "the head",
        tooth = "the tooth",
        flint = "the flint",
        mark = "the mark",
        oldox = "nostalgic ox",
        oldhouse = "nostalgic house",
        oldarm = "nostalgic arm",
        oldfish = "nostalgic fish",
        oldmanacle = "nostalgic manacle",
        oldserpent = "nostalgic serpent",
        oldpillar = "nostalgic pillar",
        oldflint = "nostalgic flint",
        oldmark = "nostalgic mark",
        tax = "the tax",
        trick = "the trick",
        joke = "the joke",
        hammer = "the hammer",
        box = "the box",
        windmill = "the windmill",
        clock = "the clock",
}
