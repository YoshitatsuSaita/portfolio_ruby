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
    kigo: '蛙' },
  { body: 'はるのうみひねもすのたりのたりかな',
    kigo: '春の海' },
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
    status: :published
  )
end

Haiku.create!(
  user: User.find_by(email: 'test@example.com'),
  body: 'したがきのはいくをかいてみたよ',
  kigo: '春風',
  status: :draft
)
