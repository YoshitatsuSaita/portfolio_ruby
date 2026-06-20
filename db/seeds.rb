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
