local pointer = {
	cry_credits = {
		idea = {
			"HexaCryonic",
		},
		art = {
			"HexaCryonic",
		},
		code = {
			"Math",
		},
	},
	dependencies = {
		items = {
			"set_cry_code",
		},
	},
	object_type = "Consumable",
	set = "Spectral",
	name = "cry-Pointer",
	key = "pointer",
	pos = { x = 11, y = 3 },
	hidden = true,
	soul_set = "Code",
	order = 2000,
	atlas = "atlasnotjokers",
	can_use = function(self, card)
		return true
	end,
	use = function(self, card, area, copier)
		G.GAME.USING_CODE = true
		G.GAME.USING_POINTER = true
		G.ENTERED_CARD = ""
		G.CHOOSE_CARD = UIBox({
			definition = create_UIBox_pointer(card),
			config = {
				align = "cm",
				offset = { x = 0, y = 10 },
				major = G.ROOM_ATTACH,
				bond = "Weak",
				instance_type = "POPUP",
			},
		})
		G.CHOOSE_CARD.alignment.offset.y = 0
		G.ROOM.jiggle = G.ROOM.jiggle + 1
		G.CHOOSE_CARD:align_to_major()
		check_for_unlock({ cry_used_consumable = "c_cry_pointer" })
	end,
	init = function(self)
		function create_UIBox_pointer(card)
			G.E_MANAGER:add_event(Event({
				blockable = false,
				func = function()
					G.REFRESH_ALERTS = true
					return true
				end,
			}))
			local t = create_UIBox_generic_options({
				no_back = true,
				colour = HEX("04200c"),
				outline_colour = G.C.SECONDARY_SET.Code,
				contents = {
					{
						n = G.UIT.R,
						nodes = {
							create_text_input({
								colour = G.C.SET.Code,
								hooked_colour = darken(copy_table(G.C.SET.Code), 0.3),
								w = 4.5,
								h = 1,
								max_length = 100,
								extended_corpus = true,
								prompt_text = localize("cry_code_enter_card"),
								ref_table = G,
								ref_value = "ENTERED_CARD",
								keyboard_offset = 1,
							}),
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							UIBox_button({
								colour = G.C.SET.Code,
								button = "pointer_apply",
								label = { localize("cry_code_create") },
								minw = 4.5,
								focus_args = { snap_to = true },
							}),
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							UIBox_button({
								colour = G.C.SET.Code,
								button = "your_collection",
								label = { localize("b_collection_cap") },
								minw = 4.5,
								focus_args = { snap_to = true },
							}),
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							UIBox_button({
								colour = G.C.RED,
								button = "pointer_apply_previous",
								label = { localize("cry_code_create_previous") },
								minw = 4.5,
								focus_args = { snap_to = true },
							}),
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							UIBox_button({
								colour = G.C.RED,
								button = "pointer_cancel",
								label = { localize("cry_code_cancel") },
								minw = 4.5,
								focus_args = { snap_to = true },
							}),
						},
					},
				},
			})
			return t
		end
		G.FUNCS.pointer_cancel = function()
			G.CHOOSE_CARD:remove()
			G.GAME.USING_CODE = false
			G.GAME.USING_POINTER = false
			G.DEBUG_POINTER = false
		end
		G.FUNCS.pointer_apply_previous = function()
			if G.PREVIOUS_ENTERED_CARD then
				G.ENTERED_CARD = G.PREVIOUS_ENTERED_CARD or ""
			end
			G.FUNCS.pointer_apply()
		end
		G.FUNCS.pointer_apply = function()
			local function apply_lower(strn)
				if type(strn) ~= string then -- safety
					strn = tostring(strn)
				end
				-- Remove content within {} and any remaining spaces
				strn = strn:gsub("%b{}", ""):gsub("%s+", "")
				--this weirdness allows you to get m and M separately
				if string.len(strn) == 1 then
					return strn
				end
				return string.lower(strn)
			end
			local current_card -- j_cry_dropshot
			local entered_card = G.ENTERED_CARD
			G.PREVIOUS_ENTERED_CARD = G.ENTERED_CARD
			current_card = Cryptid.pointergetalias(apply_lower(entered_card)) or nil
			for key, card in pairs(G.P_CENTERS) do
				if apply_lower(card.name) == apply_lower(entered_card) then
					current_card = key
				end
				if apply_lower(tostring(key)) == apply_lower(entered_card) then
					current_card = key
				end
			end

			if Cryptid.pointergetblist(current_card) then
				current_card = nil
			end
			print(current_card)

			if current_card then -- non-playing card cards
				local created = false
				if -- Joker check
					G.P_CENTERS[current_card].set == "Joker"
					and (
						G.DEBUG_POINTER -- Debug Mode
						or (
							G.P_CENTERS[current_card].unlocked -- If card discovered
							and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit -- and you have room
							and Cryptid.pointergetalias(current_card) -- and key exists
						)
					)
				then
					local card = create_card("Joker", G.jokers, nil, nil, nil, nil, current_card)
					card:add_to_deck()
					G.jokers:emplace(card)
					created = true
				end
				if -- Consumeable check
					G.P_CENTERS[current_card].consumeable
					and (
						G.DEBUG_POINTER
						or (
							#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
							and Cryptid.pointergetalias(current_card)
						)
					)
				then
					local card = create_card("Consumeable", G.consumeables, nil, nil, nil, nil, current_card)
					if card.ability.name and card.ability.name == "cry-Chambered" then
						card.ability.extra.num_copies = 1
					end
					card:add_to_deck()
					G.consumeables:emplace(card)
					created = true
				end
				if -- Voucher check
					G.P_CENTERS[current_card].set == "Voucher"
					and (
						G.DEBUG_POINTER
						or (G.P_CENTERS[current_card].unlocked and Cryptid.pointergetalias(current_card))
					)
				then
					local area
					if G.STATE == G.STATES.HAND_PLAYED then
						if not G.redeemed_vouchers_during_hand then
							G.redeemed_vouchers_during_hand = CardArea(
								G.play.T.x,
								G.play.T.y,
								G.play.T.w,
								G.play.T.h,
								{ type = "play", card_limit = 5 }
							)
						end
						area = G.redeemed_vouchers_during_hand
					else
						area = G.play
					end
					local card = create_card("Voucher", area, nil, nil, nil, nil, current_card)
					card:start_materialize()
					area:emplace(card)
					card.cost = 0
					card.shop_voucher = false
					local current_round_voucher = G.GAME.current_round.voucher
					card:redeem()
					G.GAME.current_round.voucher = current_round_voucher
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0,
						func = function()
							card:start_dissolve()
							return true
						end,
					}))
					created = true
				end
				if -- Booster check
					G.P_CENTERS[current_card].set == "Booster"
					and (G.DEBUG_POINTER or (G.P_CENTERS[current_card].unlocked and Cryptid.pointergetalias(
						current_card
					)))
					and ( -- no boosters if already in booster
						G.STATE ~= G.STATES.TAROT_PACK
						and G.STATE ~= G.STATES.SPECTRAL_PACK
						and G.STATE ~= G.STATES.STANDARD_PACK
						and G.STATE ~= G.STATES.BUFFOON_PACK
						and G.STATE ~= G.STATES.PLANET_PACK
						and G.STATE ~= G.STATES.SMODS_BOOSTER_OPENED
					)
				then
					local card = create_card("Booster", G.hand, nil, nil, nil, nil, current_card)
					card.cost = 0
					card.from_tag = true
					G.FUNCS.use_card({ config = { ref_table = card } })
					card:start_materialize()
					created = true
				end
				if created then
					G.CHOOSE_CARD:remove()
					G.GAME.USING_CODE = false
					G.GAME.USING_POINTER = false
					G.DEBUG_POINTER = false
					return
				end
			end

			for i, v in pairs(G.P_TAGS) do -- TAGS
				if Cryptid.pointergetalias(i) and not Cryptid.pointergetblist(i) then
					if v.name and apply_lower(entered_card) == apply_lower(v.name) then
						current_card = i
					end
					if apply_lower(entered_card) == apply_lower(i) then
						current_card = i
					end
					if
						apply_lower(entered_card) == apply_lower(localize({ type = "name_text", set = v.set, key = i }))
					then
						current_card = i
					end
				end
			end

			if
				current_card
				and (G.DEBUG_POINTER or (not G.P_CENTERS[current_card] and not G.GAME.banned_keys[current_card]))
			then
				local created = false
				local t = Tag(current_card, nil, "Big")
				add_tag(t)
				if current_card == "tag_orbital" then
					local _poker_hands = {}
					for k, v in pairs(G.GAME.hands) do
						if v.visible then
							_poker_hands[#_poker_hands + 1] = k
						end
					end
					t.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed("cry_pointer_orbital"))
				end
				if current_card == "tag_cry_rework" then
					--tbh this is the most unbalanced part of the card
					t.ability.rework_edition =
						pseudorandom_element(G.P_CENTER_POOLS.Edition, pseudoseed("cry_pointer_edition")).key
					t.ability.rework_key =
						pseudorandom_element(G.P_CENTER_POOLS.Joker, pseudoseed("cry_pointer_joker")).key
				end
				G.CHOOSE_CARD:remove()
				G.GAME.USING_CODE = false
				G.GAME.USING_POINTER = false
				G.DEBUG_POINTER = false
				return
			end
			for i, v in pairs(G.P_BLINDS) do
				if Cryptid.pointergetalias(i) and not Cryptid.pointergetblist(i) then
					if v.name and apply_lower(entered_card) == apply_lower(v.name) then
						current_card = i
					end
					if apply_lower(entered_card) == apply_lower(i) then
						current_card = i
					end
					if
						apply_lower(entered_card)
						== apply_lower(localize({ type = "name_text", set = "Blind", key = i }))
					then
						current_card = i
					end
				end
			end
			if
				current_card
				and not G.P_CENTERS[current_card]
				and not G.P_TAGS[current_card]
				and (G.DEBUG_POINTER or not Cryptid.pointergetblist(current_card))
			then
				local created = false
				if not G.GAME.blind or (G.GAME.blind.name == "" or not G.GAME.blind.blind_set) then
					--from debugplus
					local par = G.blind_select_opts.boss.parent
					G.GAME.round_resets.blind_choices.Boss = current_card

					G.blind_select_opts.boss:remove()
					G.blind_select_opts.boss = UIBox({
						T = { par.T.x, 0, 0, 0 },
						definition = {
							n = G.UIT.ROOT,
							config = {
								align = "cm",
								colour = G.C.CLEAR,
							},
							nodes = {
								UIBox_dyn_container(
									{ create_UIBox_blind_choice("Boss") },
									false,
									get_blind_main_colour("Boss"),
									mix_colours(G.C.BLACK, get_blind_main_colour("Boss"), 0.8)
								),
							},
						},
						config = {
							align = "bmi",
							offset = {
								x = 0,
								y = G.ROOM.T.y + 9,
							},
							major = par,
							xy_bond = "Weak",
						},
					})
					par.config.object = G.blind_select_opts.boss
					par.config.object:recalculate()
					G.blind_select_opts.boss.parent = par
					G.blind_select_opts.boss.alignment.offset.y = 0

					for i = 1, #G.GAME.tags do
						if G.GAME.tags[i]:apply_to_run({
							type = "new_blind_choice",
						}) then
							break
						end
					end
					created = true
				else
					G.GAME.blind:set_blind(G.P_BLINDS[current_card])
					ease_background_colour_blind(G.STATE)
					created = true
				end
				if created then
					G.CHOOSE_CARD:remove()
					G.GAME.USING_CODE = false
					G.GAME.USING_POINTER = false
					G.DEBUG_POINTER = false
				end
			end
			if not current_card then -- if card isn't created yet, try playing cards
				local words = {}
				for i in string.gmatch(string.lower(entered_card), "%S+") do -- not using apply_lower because we actually want the spaces here
					table.insert(words, i)
				end

				local rank_table = {
					{ "stone" },
					{ "2", "Two", "II" },
					{ "3", "Three", "III" },
					{ "4", "Four", "IV" },
					{ "5", "Five", "V" },
					{ "6", "Six", "VI" },
					{ "7", "Seven", "VII" },
					{ "8", "Eight", "VIII" },
					{ "9", "Nine", "IX" },
					{ "10", "1O", "Ten", "X", "T" },
					{ "J", "Jack" },
					{ "Q", "Queen" },
					{ "K", "King" },
					{ "A", "Ace", "One", "1", "I" },
				} -- ty variable
				local _rank = nil
				for m = #words, 1, -1 do -- the legendary TRIPLE LOOP, checking from end since rank is most likely near the end
					for i, v in pairs(rank_table) do
						for j, k in pairs(v) do
							if words[m] == string.lower(k) then
								_rank = i
								break
							end
						end
						if _rank then
							break
						end
					end
					if _rank then
						break
					end
				end
				if _rank then -- a playing card is going to get created at this point, but we can find additional descriptors
					local suit_table = {
						["Spades"] = { "spades" },
						["Hearts"] = { "hearts" },
						["Clubs"] = { "clubs" },
						["Diamonds"] = { "diamonds" },
					}
					for k, v in pairs(SMODS.Suits) do
						local index = v.key
						local current_name = G.localization.misc.suits_plural[index]
						if not suit_table[v.key] then
							suit_table[v.key] = { string.lower(current_name) }
						end
					end
					-- i'd rather be pedantic and not forgive stuff like "spade", there's gonna be a lot of checks
					-- can change that if need be
					local enh_table = {
						["m_lucky"] = { "lucky" },
						["m_mult"] = { "mult" },
						["m_bonus"] = { "bonus" },
						["m_wild"] = { "wild" },
						["m_steel"] = { "steel" },
						["m_glass"] = { "glass" },
						["m_gold"] = { "gold" },
						["m_stone"] = { "stone" },
						["m_cry_echo"] = { "echo" },
					}
					for k, v in pairs(G.P_CENTER_POOLS.Enhanced) do
						local index = v.key
						local current_name = G.localization.descriptions.Enhanced[index].name
						current_name = current_name:gsub(" Card$", "")
						if not enh_table[v.key] then
							enh_table[v.key] = { string.lower(current_name) }
						end
					end
					local ed_table = {
						["e_base"] = { "base" },
						["e_foil"] = { "foil" },
						["e_holo"] = { "holo" },
						["e_polychrome"] = { "polychrome" },
						["e_negative"] = { "negative" },
						["e_cry_mosaic"] = { "mosaic" },
						["e_cry_oversat"] = { "oversat" },
						["e_cry_glitched"] = { "glitched" },
						["e_cry_astral"] = { "astral" },
						["e_cry_blur"] = { "blurred" },
						["e_cry_gold"] = { "golden" },
						["e_cry_glass"] = { "fragile" },
						["e_cry_m"] = { "jolly" },
						["e_cry_noisy"] = { "noisy" },
						["e_cry_double_sided"] = { "double-sided", "double_sided", "double" }, -- uhhh sure
					}
					for k, v in pairs(G.P_CENTER_POOLS.Edition) do
						local index = v.key
						local current_name = G.localization.descriptions.Edition[index].name
						if not ed_table[v.key] then
							ed_table[v.key] = { string.lower(current_name) }
						end
					end
					local seal_table = {
						["Red"] = { "red" },
						["Blue"] = { "blue" },
						["Purple"] = { "purple" },
						["Gold"] = { "gold", "golden" }, -- don't worry we're handling seals differently
						["cry_azure"] = { "azure" },
						["cry_green"] = { "green" },
					}
					local sticker_table = {
						["eternal"] = { "eternal" },
						["perishable"] = { "perishable" },
						["rental"] = { "rental" },
						["pinned"] = { "pinned" },
						["banana"] = { "banana" }, -- no idea why this evades prefixing
						["cry_rigged"] = { "rigged" },
						["cry_flickering"] = { "flickering" },
						["cry_possessed"] = { "possessed" },
						["cry_absolute"] = { "absolute" },
					}
					local function parsley(_table, _word)
						for i, v in pairs(_table) do
							for j, k in pairs(v) do
								if _word == string.lower(k) then
									return i
								end
							end
						end
						return ""
					end
					local function to_rank(rrank)
						if rrank <= 10 then
							return tostring(rrank)
						elseif rrank == 11 then
							return "Jack"
						elseif rrank == 12 then
							return "Queen"
						elseif rrank == 13 then
							return "King"
						elseif rrank == 14 then
							return "Ace"
						end
					end

					-- ok with all that fluff out the way now we can figure out what on earth we're creating

					local _seal_att = false
					local _suit = ""
					local _enh = ""
					local _ed = ""
					local _seal = ""
					local _stickers = {}
					for m = #words, 1, -1 do
						-- we have a word. figure out what that word is
						-- this is dodgy spaghetti but w/ever
						local wword = words[m]
						if _suit == "" then
							_suit = parsley(suit_table, wword)
						end
						if _enh == "" then
							_enh = parsley(enh_table, wword)
							if _enh == "m_gold" and _seal_att == true then
								_enh = ""
							end
						end
						if _ed == "" then
							_ed = parsley(ed_table, wword)
							if _ed == "e_cry_gold" and _seal_att == true then
								_ed = ""
							end
						end
						if _seal == "" then
							_seal = parsley(seal_table, wword)
							if _seal == "Gold" and _seal_att == false then
								_seal = ""
							end
						end
						local _st = parsley(sticker_table, wword)
						if _st then
							_stickers[#_stickers + 1] = _st
						end
						if wword == "seal" or wword == "sealed" then
							_seal_att = true
						else
							_seal_att = false
						end -- from end so the next word should describe the seal
					end

					-- now to construct the playing card
					-- i'm doing this by applying everything but maybe it's a bit janky?

					G.CHOOSE_CARD:remove()
					G.GAME.USING_CODE = false
					G.GAME.USING_POINTER = false
					G.DEBUG_POINTER = false

					G.E_MANAGER:add_event(Event({
						func = function()
							G.playing_card = (G.playing_card and G.playing_card + 1) or 1
							local _card = create_card("Base", G.play, nil, nil, nil, nil, nil, "pointer")
							SMODS.change_base(
								_card,
								_suit ~= "" and _suit
									or pseudorandom_element(
										{ "Spades", "Hearts", "Diamonds", "Clubs" },
										pseudoseed("sigil")
									),
								_rank > 1 and to_rank(_rank) or nil
							)
							if _enh ~= "" then
								_card:set_ability(G.P_CENTERS[_enh])
							end
							if _rank == 1 then
								_card:set_ability(G.P_CENTERS["m_stone"])
							end
							if _seal ~= "" then
								_card:set_seal(_seal, true, true)
							end
							if _ed ~= "" then
								_card:set_edition(_ed, true, true)
							end
							for i = 1, #_stickers do
								_card.ability[_stickers[i]] = true
								if _stickers[i] == "pinned" then
									_card.pinned = true
								end
							end
							_card:start_materialize()
							G.play:emplace(_card)
							table.insert(G.playing_cards, _card)
							playing_card_joker_effects({ _card })
							return true
						end,
					}))
					G.E_MANAGER:add_event(Event({
						func = function()
							G.deck.config.card_limit = G.deck.config.card_limit + 1
							return true
						end,
					}))
					draw_card(G.play, G.deck, 90, "up", nil)
				end
			end
		end
	end,
}

-- TODO
-- accept raw keys (COMPLETE)
-- accept custom aliases (COMPLETE)
-- specific joker blacklist (COMPLETE)
-- joker type blacklist (see: exotics)

local aliases = {
	-- Vanilla Jokers
	j_joker = {
		"Default Joker"
	},
	j_greedy_joker = {
		"Greedy",
		"Greed"
	},
	j_lusty_joker = {
		"Lusty",
		"Lust"
	},
	j_wrathful_joker = {
		"Wrathful",
		"Wrath"
	},
	j_gluttenous_joker = {
		"Gluttenous",
		"Gluttony"
	}

	--[[ 
	Format:
		<joker key> = {
			"<alias1>",
			"<alias2>",
			...
			"<aliasN>",
		},
	]]
	-- TARGET: Add Jokers to Alias List
}

local pointeritems = {
	pointer,
}

return {
	name = "Pointer://",
	items = pointeritems,
	init = function()
		print("[CRYPTID] Inserting Pointer Aliases")
		local alify = Cryptid.pointeraliasify

		for key, aliasesTable in pairs(aliases) do
			for _, alias in pairs(aliasesTable) do
				alify(key, alias, nil)
			end
		end
	end,
}
