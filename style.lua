-- Malaysian License Plate Generator for Assetto Corsa

-- Gather plate designs
local plateDesigns = {}
for _, file in ipairs(fs.readDir('PlateTypes', '*.png')) do
    if not file:find('_nm.png') then
        local name = path.getFileNameWithoutExtension(file):gsub('_bg', '')
        plateDesigns[name] = name
    end
end

-- UI Inputs (order matters)
defineSelect('PlateDesign', plateDesigns, 'EU_Framed')
defineSelect('plateType', {'Standard', 'Special', 'Custom'}, 'Standard')
defineNumber('Generator', 4, 0, 9999, 0)   -- seed for prefix/postfix only
defineNumber('Number', 4, 0, 9999, 0)      -- numeric field (0 treated as "random")
defineText('Custom', 8, InputLength.Varying, nil) -- user custom prefix/postfix combined if needed
defineNumber('FontSize', 3, 60, 500, 130)  -- only applied to Custom

-- JPJ character rules
local skipLetters = { I=true, O=true, Z=true } -- globally skipped
local allowedLetters = {}
for c = string.byte('A'), string.byte('Z') do
    local ch = string.char(c)
    if not skipLetters[ch] then table.insert(allowedLetters, ch) end
end

-- Reserved full series (prefix + series to avoid)
local reservedFullSeries = {
    "JMF", "JVF", "JYB", "TCS",
}
local function isReservedFull(full)
    if not full then return false end
    for _, v in ipairs(reservedFullSeries) do
        if full == v then return true end
    end
    return false
end

-- State & division config
-- fields:
--   state: human name
--   prefix: leading prefix string
--   seriesLength: number of letters appended AFTER prefix (between prefix and number)
--   postfixLength: number of letters appended AFTER the number (suffix). 0 = none.
--   hasDivision: boolean (if true, a division letter is appended to the prefix)
--   division: array of division letters (used when hasDivision = true)
--   annual: boolean (for Putrajaya F sequences that are issued annually)
--   extended: table for special extended-series handling (e.g., W)
--   forbiddenLetters: table set of letters to exclude from pool for this state (optional)
local plateData = {
    -- Peninsular (standard xxx ####)
    { state="Perak", prefix="A", seriesLength=2, postfixLength=0 },
    { state="Selangor", prefix="B", seriesLength=2, postfixLength=0 },
    { state="Pahang", prefix="C", seriesLength=2, postfixLength=0 },
    { state="Kelantan", prefix="D", seriesLength=2, postfixLength=0 },
    { state="Johor", prefix="J", seriesLength=2, postfixLength=0 },
    { state="Kedah", prefix="K", seriesLength=2, postfixLength=0 },
    { state="Malacca", prefix="M", seriesLength=2, postfixLength=0 },
    { state="Negeri Sembilan", prefix="N", seriesLength=2, postfixLength=0 },
    { state="Penang", prefix="P", seriesLength=2, postfixLength=0 },
    { state="Perlis", prefix="R", seriesLength=2, postfixLength=0 },
    { state="Terengganu", prefix="T", seriesLength=2, postfixLength=0 },

    -- Kuala Lumpur variants
    { state="Kuala Lumpur (new V)", prefix="V", seriesLength=2, postfixLength=0 },
    -- extended W: supports left-series (0..leftMax) + number + rightSuffix (postfixLength)
    { state="Kuala Lumpur (old W, extended)", prefix="W", extended={ leftMax=2 }, seriesLength=0, postfixLength=1 },

    -- Islands / Territories
    { state="Langkawi", prefix="KV", seriesLength=0, postfixLength=1 }, -- KV #### x
    { state="Putrajaya", prefix="F", seriesLength=1, postfixLength=0, annual=true }, -- F sequences are issued annually
    { state="Labuan", prefix="L", seriesLength=2, postfixLength=0 }, -- Labuan uses Peninsular-style L series

    -- Sabah (Sdx #### x): S + division letter + series letters + numbers + suffix letter
    { state="Sabah", prefix="S", hasDivision=true,
      division={'A','B','D','J','K','M','S','T','U','W','Y'},
      seriesLength=1, postfixLength=1,
      forbiddenLetters = { Q=true, S=true } }, -- Historically Q and S restricted in suffix

    -- Sarawak (Qdx #### x): Q + division + series letters + numbers + suffix letter
    { state="Sarawak", prefix="Q", hasDivision=true,
      division={'A','B','C','D','K','L','M','Q','R','S','T'},
      seriesLength=1, postfixLength=1 },
}

-- Special prefix pools (kept from your earlier data)
local specialPrefixes = {
    ev = {
        { prefix = "EV", category = "Electric Vehicles" }
    },
    active = {
        { prefix = {"GOLD","FFF","MADANI","PETRA","ANSARA","VIPS","PROTON","PERODUA","LOTUS","NAZA","UUU","IQ","QQ","UA","E","G","GG","GT","GTR","G1M","GP","1M4U","A1M","Chancellor"} },
        { prefix = {"M"}, postfix = {"M"} },
        { prefix = {"A"}, postfix = {"A"} },
        { prefix = {"PROTON","PERODUA","LOTUS","NAZA"} },
        { prefix = {"UUU","IQ","QQ","UA","E"} },
        { prefix = {"G","GG","GT","GTR","G1M","GP"} },
        { prefix = {"G"}, postfix = {"G"} },
        { prefix = {"1M4U","A1M","Chancellor"} }
    },
    commemorative = {
        { prefix = {"Malaysia","Putrajaya"}, font = {"calistomtitalic.ttf"} },
    },
    dormant = {
        { prefix = {"WAJA","Satria"} },
        { prefix = {"SUKOM","XIIINAM","XOIC","XXVIASEAN","XXXIDB"} },
        { prefix = {"NBOS","PATRIOT","NAAM","K1M","RAPID","SAS"} },
    }
}

-- Helpers
local function safeNum(v, d) local n = tonumber(v) if not n then return d end return n end
local function clamp(v, a, b) if v < a then return a end if v > b then return b end return v end
local function randInt(a,b) return math.random(a,b) end

local function pickFrom(tbl)
    if not tbl or #tbl == 0 then return nil end
    return tbl[math.random(#tbl)]
end

local function formatNumberVal(num)
    local n = tonumber(num) or 0
    if n <= 0 then return nil end
    return tostring(n):gsub("^0+", "")
end

local function getNumberString(numOverride)
    return formatNumberVal(numOverride) or tostring(randInt(1, 9999))
end

local function textSizeFor(prefix, number, postfix, defaultSize)
    local len = #((prefix or "") .. (number or "") .. (postfix or ""))
    local minSize, decayRate = 24, 0.09
    return math.min(defaultSize, math.max(minSize, math.floor(defaultSize * math.exp(-decayRate * (len - 7)))))
end

-- Build series (sequence of letters) of length `len`
-- optional second arg: pool (array of letters). defaults to global allowedLetters
local function buildSeries(len, pool)
    if len <= 0 then return "" end
    local out = {}
    local p = pool or allowedLetters
    if not p or #p == 0 then return "" end
    for i = 1, len do
        table.insert(out, p[math.random(#p)])
    end
    return table.concat(out)
end

-- Build a per-state allowed pool (filters global allowedLetters by st.forbiddenLetters)
local function makePoolForState(st)
    if st and st.allowedLetters and #st.allowedLetters > 0 then
        return st.allowedLetters
    end
    if not st or not st.forbiddenLetters then return allowedLetters end
    local pool = {}
    for _, ch in ipairs(allowedLetters) do
        if not st.forbiddenLetters[ch] then table.insert(pool, ch) end
    end
    return pool
end

-- Safe picker: never returns nil (returns empty string if table invalid)
local function pickFrom(tbl)
    if not tbl or #tbl == 0 then return "" end
    return tbl[math.random(#tbl)] or ""
end

-- Build series (sequence of letters) of length `len`
local function buildSeries(len, pool)
    if not len or len <= 0 then return "" end
    local out = {}
    local p = pool or allowedLetters
    if not p or #p == 0 then return "" end
    for i = 1, len do
        table.insert(out, p[math.random(#p)] or "")
    end
    return table.concat(out)
end

-- Pick a safe random series (avoids reserved, but won't freeze)
local function safeSeries(len, pool, avoidPrefix)
    if len <= 0 then return "" end
    pool = pool or allowedLetters
    local attempt = ""
    for tries = 1, 5 do
        attempt = buildSeries(len, pool)
        if not avoidPrefix or not isReservedFull(avoidPrefix .. attempt) then
            return attempt
        end
    end
    -- Fallback: ignore reserved filter
    return buildSeries(len, pool)
end

-- Build series but avoid reservedFull combos. Returns (seriesString, postfixString) — always strings.
local function buildSeriesAvoidReserved(prefix, seriesLen, postfixLen, st, tries)
    tries = tries or 20
    local pool = makePoolForState(st)
    for i = 1, tries do
        local series = buildSeries(seriesLen, pool) or ""
        local postfix = (postfixLen and postfixLen > 0) and (buildSeries(postfixLen, pool) or "") or ""
        local full = (prefix or "") .. series .. postfix
        if not isReservedFull(full) then
            return series, postfix
        end
    end
    -- fallback
    return buildSeries(seriesLen, pool) or "", (postfixLen and buildSeries(postfixLen, pool) or "") or ""
end


-- Generate JPJ-type prefix + postfix ONLY (main code handles number)
-- returns: prefixString, postfixString  (both always strings)
local function generateJPJPrefixAndPostfix()
    local st = plateData[math.random(#plateData)]
    st = st or plateData[1]
    local prefix = st.prefix or ""

    -- Division letter (Sabah/Sarawak)
    if st.hasDivision and type(st.division) == "table" and #st.division > 0 then
        local div = pickFrom(st.division)
        if div ~= "" then prefix = prefix .. div end
    end

    local pool = makePoolForState(st)

    -- Extended handling (e.g., W-style). We produce a prefix that may include inserted left-series,
    -- but still return only (prefix, postfix) since your main function expects that.
    if st.extended then
        local leftMax = (st.extended.leftMax and tonumber(st.extended.leftMax)) or 0
        local leftLen = math.random(0, leftMax)
        local leftSeries = buildSeries(leftLen, pool) or ""

        -- optional midLen if you want a second inserted block (not used by default)
        local midLen = (st.extended.midLen and tonumber(st.extended.midLen)) or 0
        local midSeries = buildSeries(midLen, pool) or ""

        -- ensure we avoid reserved combos for prefix+left+mid
        for i = 1, 20 do
            local fullLeft = (prefix or "") .. leftSeries .. midSeries
            if not isReservedFull(fullLeft) then break end
            leftSeries = buildSeries(leftLen, pool) or ""
            midSeries = buildSeries(midLen, pool) or ""
        end

        prefix = prefix .. leftSeries .. midSeries

        -- number (returned to caller as separate, main code handles number placement)
        local postfix = ""
        if st.postfixLength and st.postfixLength > 0 then
            for i = 1, 20 do
                postfix = buildSeries(st.postfixLength, pool) or ""
                if not isReservedFull(prefix .. postfix) then break end
            end
        end

        return prefix or "", postfix or ""
    end

    -- Non-extended flow
    if st.seriesLength and st.seriesLength > 0 then
        local series, _ = buildSeriesAvoidReserved(prefix, st.seriesLength, 0, st, 20)
        series = series or ""
        prefix = prefix .. series
    end

    local postfix = ""
    if st.postfixLength and st.postfixLength > 0 then
        for i = 1, 20 do
            postfix = buildSeries(st.postfixLength, pool) or ""
            if not isReservedFull(prefix .. postfix) then break end
        end
    end

    return prefix or "", postfix or ""
end

-- Cache 
local lastPlateType, lastPlateDesign, lastGenerator = nil, nil, nil
local lastStandard, lastSpecial = nil, nil

-- Main generator function
-- signature matches define* order:
-- (PlateDesign, plateType, Generator, Number, Custom, FontSize)
return function(PlateDesign, plateType, Generator, Number, Custom, FontSize)

    drawPlateText = nil

    -- default text props (design script may override text.size/font)
    text.font = 'arialbold.ttf'
    text.color = '#FFFFFF'
    text.kerning = -4
    text.spaces = 48

    -- sanitize inputs and clamp font slider (fast slider safe)
    local gen = safeNum(Generator, 0)
    local numOverride = safeNum(Number, 0)
    local fontNum = safeNum(FontSize, 0)
    local safeFont = (fontNum > 0) and clamp(fontNum, 60, 500) or nil

    -- load design script if present (design may override text.size)
    local designScript = string.format("PlateTypes/%s.lua", PlateDesign)
    if fs.exists(designScript) then dofile(designScript) end
    local designDefaultSize = tonumber(text.size) or 48

    -- set plate textures & lighting
    plate.background = string.format("PlateTypes/%s_bg.png", PlateDesign)
    plate.normals = string.format("PlateTypes/%s_nm.png", PlateDesign)
    plate.light = -90

    -- prepare outputs
    local prefixOut, numberOut, postfixOut = "", "", ""

    -- Number always controlled by slider if >0, else random 1..9999
    if numOverride > 0 then
        numberOut = getNumberString(numOverride)
    else
        numberOut = tostring(randInt(1, 9999))  -- Ensure random number generation when slider is 0
    end

    if plateType == "Custom" then
            -- Custom: let user supply combined text (Custom field). Only output Custom as per user input
            local customText = (Custom and tostring(Custom) ~= "") and tostring(Custom) or ""
            local parts = {}
            for tok in customText:gmatch("%S+") do table.insert(parts, tok) end
            if #parts == 1 then
                prefixOut = parts[1]
                numberOut = ""
                postfixOut = ""
            elseif #parts == 2 then
                prefixOut = parts[1]
                numberOut = ""
                postfixOut = parts[2]
            elseif #parts >= 3 then
                prefixOut = parts[1]
                numberOut = ""
                postfixOut = parts[#parts]
            else
                prefixOut, numberOut, postfixOut = "", "", ""
            end
            -- Font size controlled only in Custom mode
            if safeFont then text.size = safeFont else text.size = designDefaultSize end

    elseif plateType == "Standard" then
        -- regenerate prefix/postfix only when plateType/design/gen change (Number changes DO NOT re-roll)
        local regen = (plateType ~= lastPlateType) or (PlateDesign ~= lastPlateDesign) or (gen ~= (lastGenerator or -1)) or (not lastStandard)
        if regen then
            prefixOut, postfixOut = generateJPJPrefixAndPostfix(gen)
            lastStandard = { prefix = prefixOut, postfix = postfixOut }
        else
            prefixOut = (lastStandard and lastStandard.prefix) or ""
            postfixOut = (lastStandard and lastStandard.postfix) or ""
        end
        text.size = textSizeFor(prefixOut, numberOut, postfixOut, designDefaultSize)

    elseif plateType == "Special" then
        local specialList = {}
        if PlateDesign == "EV" then
            for _, v in ipairs(specialPrefixes.ev) do table.insert(specialList, v) end
            for _, v in ipairs(specialPrefixes.active) do table.insert(specialList, v) end
        else
            for _, v in ipairs(specialPrefixes.active) do table.insert(specialList, v) end
            for _, v in ipairs(specialPrefixes.commemorative or {}) do table.insert(specialList, v) end
            for _, v in ipairs(specialPrefixes.dormant) do table.insert(specialList, v) end
        end

        local chosen = specialList[math.random(#specialList)]
        if chosen then
            if type(chosen.prefix) == "table" then
                prefixOut = chosen.prefix[math.random(#chosen.prefix)]
            else
                prefixOut = chosen.prefix or ""
            end
            if chosen.postfix then
                if type(chosen.postfix) == "table" then
                    postfixOut = chosen.postfix[math.random(#chosen.postfix)]
                else
                    postfixOut = chosen.postfix or ""
                end
            else
                postfixOut = ""
            end
            if chosen.font then
                text.font = (type(chosen.font) == "table" and chosen.font[1]) or chosen.font
            end
        end
        text.size = textSizeFor(prefixOut, numberOut, postfixOut, designDefaultSize)
    end

    -- persist cache keys (use numeric gen)
    lastPlateType = plateType
    lastPlateDesign = PlateDesign
    lastGenerator = gen

    -- assemble plate text and draw
    local parts = {}
    if prefixOut ~= "" then table.insert(parts, prefixOut) end
    if numberOut ~= "" then table.insert(parts, numberOut) end
    if postfixOut ~= "" then table.insert(parts, postfixOut) end
    local plateText = table.concat(parts, " ")
    plateText = plateText:match("^%s*(.-)%s*$") or ""

    if type(drawPlateText) == "function" then
        if PlateDesign:sub(1,2) == "UK" then
            -- UK-style function expects separate components
            drawPlateText(nil, prefixOut, numberOut, postfixOut)
        else
            drawPlateText(plateText)
        end
    end
end
