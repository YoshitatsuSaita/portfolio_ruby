User.create!(name: '管理者',
             email: 'admin@example.com',
             password: 'password',
             password_confirmation: 'password',
             admin: true,
             profile_text: '俳句アプリの管理者です。')

User.create!(name: '一般ユーザー',
             email: 'test@example.com',
             password: 'password',
             password_confirmation: 'password',
             admin: false,
             profile_text: '俳句を楽しんでいます。')

60.times do |n|
  name = Faker::Name.name
  email = "sample-#{n + 1}@example.com"
  password = 'password'
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               profile_text: Faker::Lorem.paragraph)
end

haiku_data = [
  { body: 'ふるいけやかわずとびこむみずのおと',
    kigo: '蛙', theme: '自然' },
  { body: 'はるのうみひねもすのたりのたりかな',
    kigo: '春の海', theme: '自然' },
  { body: 'しずかさやいわにしみいるせみのこえ',
    kigo: '蝉' },
  { body: 'あらうみやさどによこたうあまのがわ',
    kigo: '天の川' },
  { body: 'かれえだにからすのとまりけりあきのくれ',
    kigo: '秋の暮' },
  { body: 'ふるゆきやめいじはとおくなりにけり',
    kigo: '降る雪' },
  { body: 'いくたびもゆきのふかさをたずねけり',
    kigo: '雪' },
  { body: 'はつゆめにふるさとをみてなみだかな',
    kigo: '初夢' }
]

users = User.all.to_a
haiku_data.each do |data|
  Haiku.create!(
    user: users.sample,
    body: data[:body],
    kigo: data[:kigo],
    theme: data[:theme],
    status: :published
  )
end

test_user = User.find_by(email: 'test@example.com')

Haiku.create!(
  user: test_user,
  body: 'あさがおやつるべとられてもらいみず',
  kigo: '朝顔',
  theme: '自然',
  status: :published
)

Haiku.create!(
  user: test_user,
  body: 'したがきのはいくをかいてみたよ',
  kigo: '春風',
  theme: '自然',
  status: :draft
)

Haiku.create!(
  user: test_user,
  body: 'なつのかぜふくやまのはのゆれるおと',
  kigo: '夏の風',
  theme: '自然',
  status: :submitted_to_admin
)

Haiku.create!(
  user: users.sample,
  body: 'あきのそらたかくすんだるつきのかげ',
  kigo: '秋の空',
  status: :submitted_to_admin
)

admin = User.find_by(email: 'admin@example.com')
published_haikus = Haiku.published.to_a
reviewers = users.reject(&:admin?)

published_haikus.first(4).each do |haiku|
  reviewers.sample(3).each do |reviewer|
    next if reviewer == haiku.user

    Review.create!(
      user: reviewer,
      haiku: haiku,
      score: rand(1..5),
      comment: [
        '素晴らしい句ですね。',
        '季語の使い方が見事です。',
        '情景が目に浮かびます。',
        '独特の世界観があります。'
      ].sample
    )
  end
end

Review.create!(
  user: admin,
  haiku: published_haikus.first,
  score: 5,
  comment: '見事な一句です。',
  correction_body: 'ふるいけやかはづとびこむみづのおと',
  correction_reason: '旧仮名遣いに添削しました。'
)

KigoExplanation.create!(
  kigo_word: '蛙',
  season: '春',
  explanation: '春の季語。古くから俳句に詠まれてきた両生類。' \
               '水辺で鳴く声が春の訪れを告げる。' \
               '松尾芭蕉の「古池や」の句で特に有名。'
)

KigoExplanation.create!(
  kigo_word: '春の海',
  season: '春',
  explanation: '春の季語。穏やかに凪いだ春の海の情景。' \
               '与謝蕪村の「春の海ひねもすのたりのたりかな」で知られる。'
)

KigoExplanation.create!(
  kigo_word: '蝉',
  season: '夏',
  explanation: '夏の季語。夏に鳴く昆虫の総称。' \
               '松尾芭蕉の「閑さや岩にしみ入る蝉の声」が代表句。'
)
