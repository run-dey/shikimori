module Types
  module Achievement
    NEKO_GROUPS = %i[common genre franchise]
    NekoGroup = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_GROUPS)

    # rubocop:disable LineLength
    NEKO_IDS = {
      NekoGroup[:common] => %i[
        test

        animelist

        otaku
        fujoshi
        yuuri

        tsundere
        yandere
        kuudere
        moe
        gar
        oniichan
        longshounen
        shortie
        oldfag
        sovietanime
      ],
      NekoGroup[:genre] => %i[
        comedy
        romance
        fantasy
        historical
        mahou_shoujo
        dementia_psychological
        mecha
        slice_of_life
        scifi
        supernatural

        action
        drama
        horror_thriller
        josei
        kids
        military
        mystery
        police
        seinen
        space
        sports

        music
      ],
      NekoGroup[:franchise] => %i[
        fullmetal_alchemist gintama ginga_eiyuu_densetsu hunter_x_hunter hanamonogatari haikyuu code_geass mushishi hajime_no_ippo rurouni_kenshin boku_no_hero_academia natsume_yuujinchou suzumiya_haruhi_no_yuuutsu bakuman fate_zero koro_sensei_q jojo_no_kimyou_na_bouken megalo_box aria_the_ova uchuu_kyoudai ghost_in_the_shell slam_dunk kuroko_no_basket kuroshitsuji major shokugeki_no_souma yuu_yuu_hakusho gundam yamato detective_conan berserk magi diamond_no_ace tsubasa cardcaptor_sakura umineko_no_naku_koro_ni one_piece sket_dance inuyasha dragon_ball initial_d durarara nanatsu_no_taizai working saint_seiya vivid_strike maison_ikkoku chiba_pedal junjou_romantica lupin_iii glass_no_kamen boruto dmatsu_san hikaru_no_go eureka_seven full_metal_panic persona fairy_tail hidamari_sketch doraemon toaru_majutsu_no_index kindaichi_shounen_no_jikenbo school_rumble slayers tennis_no_ouji_sama city_hunter snow_halation nurarihyon_no_mago touch sword_art_online muumin ushio_to_tora jigoku_shoujo macross amon tenchi_muyou saiyuuki_gaiden moon_pride nen_joou hokuto_no_ken mahoujin_guruguru digimon_savers votoms_finder bleach mazinkaiser transformers pokemon yes_precure urusei_yatsura hetalia tegamibachi hayate_no_gotoku minipato ranma black_jack genshiken to_love_ru space_cobra aikatsu getter_robo ojamajo_doremi garo negima minami_ke blood kimagure_orange_road fushigi_yuugi pripara dragon_quest utawarerumono shakugan_no_shana soukyuu_no_fafner tales_of_gekijou puchimas zero_no_tsukaima toriko locker_room aa_megami_sama senki_zesshou_symphogear grendizer_giga zettai_karen_children konjiki_no_gash_bell saki casshern candy_candy taiho_shichau_zo yu_gi_oh seiren mai_hime selector_spread_wixoss captain_tsubasa force_live baki tiger_mask saber_marionette_j el_hazard galaxy_angel cardfight_vanguard cyborg rean_no_tsubasa gall_force d_c kinnikuman super_robot_taisen_og hack_gift futari_wa_milky_holmes aquarion_evol di_gi_charat dirty_pair angelique cutey_honey mahou_no_princess_minky_momo ehon_yose to_heart sakura_taisen ginga_senpuu_braiger ikkitousen juusenki_l_gaim sonic choujuu_kishin_dancougar queen_s_blade haou_daikei_ryuu_knight super_doll_licca_chan ultraman iron_man obake_no_q_tarou pro_golfer_saru
      ]
    }
    # rubocop:enable LineLength
    INVERTED_NEKO_IDS = NEKO_IDS.each_with_object({}) do |(group, ids), memo|
      ids.each { |id| memo[id] = NekoGroup[group] }
    end
    ORDERED_NEKO_IDS = INVERTED_NEKO_IDS.keys

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORDERED_NEKO_IDS)
  end
end
