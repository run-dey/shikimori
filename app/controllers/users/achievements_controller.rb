class Users::AchievementsController < ProfilesController
  before_action :additional_breadcrumbs, except: [:index]
  before_action { og page_title: i18n_t('achievements') }
  before_action :check_access

  STUDIOS_LINE_COUNT = 8
  ACHIEVEMENTS_PER_ROW = 4

  ACHIEVEMENTS_CLUB_USER_IDS = [
    24332,38944,46395,106,29834,40510,2698,45072,43529,48601,47714,19796,24448,26383,43139,2881,13580,22262,42046,1483,43993,181,2320,2567,1043,2481,392,7560,16410,533,38622,17008,24977,1758,8705,2043,25714,1192,25069,3477,22962,41846,20646,8637,45993,4814,3523,41089,8102,2750,45441,33908,13361,39871,8947,41996,2718,1897,22,519,717,1237,31660,6956,14792,1096,28601,12834,46880,35933,9360,34415,21298,12103,3711,32996,20305,45124,8962,4475,20162,17967,44245,5255,31360,6356,21990,8543,23166,31885,21143,8583,43994,25896,46257,17211,3751,2899,1627,28574,35,30214,28145,932,10014,10112,27664,47726,35068,2204,1945,12965,15264,11496,8674,12308,20202,36388,44626,40043,47750,206,27487,35705,4332,20171,19026,38771,20012,35191,19826,4356,2988,16962,15299,11698,38264,12023,24162,22007,4964,6683,15647,7642,46018,39022,50704,23002,87,17767,24525,23893,23778,43,35439,4114,42541,16148,4193,4261,11874,18498,21507,14439,9484,3052,36908,19975,6316,5779,2351,25,5414,29965,11,6141,7531,8047,41649,192,31785,3865,29386,29682,3714,34807,16401,42045,17423,21538,15555,27165,18929,8834,864,34148,29265,20777,23319,14503,15511,33098,24897,4981,10366,41878,14459,9374,40539,11706,6830,45639,7426,3783,4099,24114,40145,19,15079,2,35186,16282,9129,6287,945,24518,385,42132,30037,5586,28569,541,11197,43340,4845,33387,30543,21077,3015,26446,36861,7909,54671,12594,1765,45026,16725,525,1798,43342,45502,30789,6391,54086,12811,55984,98,9221,9047,36019,1338,14546,27751,2414,8099,48271,23206,42218,34803,44037,10206,6788,44943,19189,27688,22525,31720,28101,48224,14706,28259,30952,13981,10980,52837,55489,57139,23656,55019,51942,51029,45821,51121,18004,33522,30858,17092,61929,47594,35605,16513,49585,16189,54892,50587,1859,17461,50758,19353,66647,67373,477,53248,52060,64330,58791,71664,63609,63951,9560,46259,54465,66304,29832,30196,25441,77680,24873,23869,75352,53157,60226,64408,79106,31862,80074,73067,80343,41479,51562,78758,71938,38043,64613,72962,50593,83591,75663,14830,539,30030,16178,9400,85014,85778,60454,47976,66661,45408,72085,34042,79001,25487,83614,76624,70406,14168,71964,71075,54512,89231,21120,87121,23139,89877,89661,39384,74988,64202,41960,88704,72466,54831,72720,90733,48103,76535,54479,85653,91949,11467,91191,70781,70850,20113,38797,20584,16642,93825,24536,70881,21495,60198,57723,76750,66340,23972,46935,49817,64631,83848,15816,89954,87229,96008,92570,93640,28880,67289,43905,84378,97854,49662,98009,98160,98193,98527,72033,98690,30854,99715,65845,51798,28769,98758,100528,48328,3395,36744,35991,101546,49924,75202,88543,77730,85793,102930,37105,80980,47785,12104,101583,1645,105154,57953,45432,65364,2046,6819,106397,104575,75347,74228,14911,143,107237,96381,48126,95421,105678,95664,97484,109983,110290,88919,29041,96527,110826,54138,92532,112249,99709,48596,113061,74466,51013,113881,44318,88002,112541,114450,57523,79233,106609,99337,114257,115575,30063,100971,104478,94545,27538,109463,13201,59951,88659,109309,99619,117734,109458,105613,118638,118830,47889,119969,3798,37602,114987,87798,114318,18634,120405,104630,30626,121487,71429,53726,121770,37230,17016,123245,123393,48710,52740,124759,50269,62703,89060,113015,13028,79900,126157,93653,25738,14257,88065,121172,44163,83265,125887,127769,109369,41555,3543,54951,25050,123803,128785,80804,129806,123152,85349,123855,55680,108673,86751,96480,62474,32966,77965,126369,2514,96487,85404,48869,134286,79482,112000,135065,47755,93880,67190,107581,116982,117920,97299,120527,114619,64772,68948,52125,10620,131807,126407,75042,25767,116268,1457,95293,139236,130519,78519,31665,136912,132158,40331,90944,69750,12123,139686,31178,133584,124489,122660,124109,65149,124697,51196,130573,74722,107474,33450,147530,37877,107959,140664,149418,35372,45454,39666,87660,41175,95736,144331,97804,56440,135681,151919,25003,147240,91575,112755,98459,96154,85636,133072,154195,46239,119207,156663,46566,157163,113953,34693,155193,159167,128947,149987,121803,158754,20886,159796,86359,122846,72940,49533,164225,165831,26691,38132,109589,136563,140054,141647,167551,167958,45562,136253,133075,169165,121602,27428,94368,147291,170867,80732,80281,122956,54595,88645,59825,62754,168761,173185,140912,10904,135806,173520,29025,59190,170164,24783,99840,84722,16876,9266,140080,118442,178486,117054,179287,176820,179478,179321,171943,80095,112711,15874,170248,134991,44236,142532,175917,131917,155152,144509,175073,31115,130395,64239,140659,181977,23153,100981,85280,24922,120970,65258,50641,112353,44729,41607,138042,138094,67929,69414,53658,15242,187545,176747,170614,24537,55602,115574,150201,186937,135386,182135,189607,30,79747,79108,116299,87859,93522,180814,113364,61309,128912,186198,25798,192929,89018,58466,77301,96077,21893,140501,55328,194533,164979,131922,165986,120294,142337,193874,181978,101832,31251,197289,79317,196310,124092,169737,147059,178907,94994,191027,181173,73556,91261,94075,131799,122155,175040,44793,45041,7931,115788,120254,202815,65860,121111,198050,170304,202058,199834,178966,86587,137080,75677,67313,137740,207312,66954,80216,205102,198553,167851,140246,123087,194529,100979,46492,171979,181701,177947,70740,123891,195853,38628,10901,38297,137041,141717,154908,154650,197492,48488,212575,177375,138516,143433,214398,74918,26109,95401,180310,193224,215527,199951,212897,61478,133074,128816,157239,212721,21373,183411,150844,219753,87788,209903,189474,73914,19143,102237,151155,136380,222839,91143,197036,23879,224255,208305,208101,163718,119524,127836,144384,168146,79031,190322,130873,79845,138115,140236,146644,97748,207301,20226,235110,231405,133618,226201,11511,134820,72620,174621,172532,72292,237037,96850,134505,90474,14634,64835,216262,19463,210731,176896,189059,20173,241259,242673,201872,208180,244042,235519,242478,216600,193448,92579,244007,125312,130339,246437,94179,204405,246880,30382,123226,81113,59847,13783,134503,186552,133330,3977,249050,248457,30761,178505,232944,13419,30702,149221,215114,107563,170382,215375,242049,250439,33149,124507,127256,170108,41299,222272,255027,252195,118049,42241,256353,102693,65296,174179,187610,51093,106466,231511,239147,53134,246577,172250,233074,136160,230658,209082,20846,261347,261904,261569,234614,232111,5061,251660,262888,63608,2225,111412,50525,245883,206983,177501,1255,266753,141127,139663,247963,238007,115311,109637,263813,95193,146973,260502,182068,164910,60381,188481,182007,271696,269866,232715,271614,215496,118655,111613,134229,205266,96037,142814,268549,272443,131906,262557,109503,196189,203134,110169,164562,215621,61682,236230,272242,279083,85600,158484,278964,228532,279292,280614,135586,120614,281557,211221,272189,273018,283086,132318,242465,36788,76661,98585,254929,139081,152660,118697,93286,286691,276816,278193,279414,286928,114493,37249,274773,246823,136680,219270,165980,289736,77864,40584,76538,150226,205706,135407,155068,142218,238593,172976,71456,120591,67113,277916,292604,269499,91890,3795,224126,8882,80853,293384,134935,117200,101976,248901,57113,23214,228678,287146,224606,276232,295512,76993,296011,279185,186800,296304,189738,178787,19631,297294,141197,30964,213997,29326,67780,73685,254680,74860,284664,75475,299585,220167,133665,301460,63053,194136,302198,265439,273724,292164,266503,131900,297209,47764,75233,251273,292025,275340,111266,246203,48390,235930,283181,241389,256281,83533,73967,306469,221926,307973,200228,213307,33985,85964,307742,309653,22907,73715,157758,202391,233083,88088,267975,302160,303661,291133,176985,253634,312656,245917,21246,20330,175026,213320,200599,297504,314697,21190,296014,316000,149468,69971,311988,27559,45421,316924,234001,138406,317249,285389,18636,299570,307027,317972,261390,86819,306042,39071,237350,149668,210413,24546,97188,222141,36814,79401,143432,127150,135725,11380,50750,270717,309524,293843,1,188,210,861,9158,16398,40201,94,3824,102598,316748,164891,1822,24655,42175,297792,317257,322862,290274,59770,49816,84020,322915,71629,125725,256951,230637,259073,24099,324078,324081,167671,319846,293077,218652,156228,324801,278167,298613,10882,202787,17694,325229,313061,134567,248523,149469,257033,202630,66620,137197,80969,324264,322452,138177,281275,262951,278540,87734,329980,88191,284396,307481,191524,323192,182791,329348,279849,297156,225576,295049,330423,296295,167800,43821,77637,26085,177849,316589,193507,320507,104042,334271,135013,187965,156518,295444,93677,336318,131581,58482,295540,289473,77362,239399,46957,207726,253092,204657,121525,85948,337309,282647,319740,317352,272004,339219,253631,238580,59888,230131,194193,103347,323591,263846,301775,55541,321696,257817,64274,25342,197671,252320,254587,323066,248480,294416,333938,95818,314670,301694,210898,343096,323140,175864,9950,157586,221102,273547,334046,75260,176288,58951,100600 # rubocop:disable all
  ]

  def index
    @common_achievements = user_achievements.select(&:common?)
    @genre_achievements = user_achievements.select(&:genre?)
    @franchise_achievements = user_achievements.select(&:franchise?)

    @missing_franchise_achievements = NekoRepository.instance
      .select(&:franchise?)
      .take(
        missing_franchise_achievements_count(
          @genre_achievements.size, @franchise_achievements.size
        )
      )
  end

  def franchise
    og page_title: t('achievements.group.franchise')

    @all_franchise_achievements = NekoRepository.instance.select(&:franchise?)
    @user_franchise_achievements = user_achievements.select(&:franchise?)
  end

private

  def check_access
    return if Rails.env.development?
    return if current_user&.admin?
    return if ACHIEVEMENTS_CLUB_USER_IDS.include(@user.id)
    return if @user.nickname == 'test2'

    raise ActiveRecord::RecordNotFound
  end

  def additional_breadcrumbs
    @back_url = profile_achievements_url(@resource)
    breadcrumb i18n_i('title'), @back_url
  end

  def user_achievements
    @user_achievements ||= @user.achievements
      .sort_by(&:sort_criteria)
      .group_by(&:neko_id)
      .map(&:second)
      .map(&:last)
  end

  def missing_franchise_achievements_count(
    genre_achievements_count,
    franchise_achievements_count
  )
    count = [
      (genre_achievements_count * 6.66).round -
        STUDIOS_LINE_COUNT -
        franchise_achievements_count,
      0
    ].max

    count +
      (ACHIEVEMENTS_PER_ROW -
       (franchise_achievements_count + count) % ACHIEVEMENTS_PER_ROW
      )
  end
end
