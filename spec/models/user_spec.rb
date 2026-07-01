require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    context '名前が空の場合' do
      it '無効であること' do
        user.name = ''
        expect(user).not_to be_valid
      end
    end

    context '名前が50文字を超える場合' do
      it '無効であること' do
        user.name = 'a' * 51
        expect(user).not_to be_valid
      end
    end

    context 'メールアドレスが空の場合' do
      it '無効であること' do
        user.email = ''
        expect(user).not_to be_valid
      end
    end

    context 'メールアドレスが100文字を超える場合' do
      it '無効であること' do
        user.email = "#{'a' * 89}@example.com"
        expect(user).not_to be_valid
      end
    end

    context 'メールアドレスの形式が不正な場合' do
      it '無効であること' do
        invalid_addresses = %w[
          user@example,com
          user_at_foo.org
          user.name@example.
        ]
        invalid_addresses.each do |addr|
          user.email = addr
          expect(user).not_to be_valid
        end
      end
    end

    context 'メールアドレスが重複する場合' do
      it '無効であること' do
        duplicate_user = user.dup
        duplicate_user.email = user.email.upcase
        expect(duplicate_user).not_to be_valid
      end
    end

    context 'パスワードが6文字未満の場合' do
      it '無効であること' do
        user.password = 'a' * 5
        user.password_confirmation = 'a' * 5
        expect(user).not_to be_valid
      end
    end
  end

  describe 'メールアドレスの小文字化' do
    it '保存時に小文字に変換されること' do
      mixed_email = 'Foo@ExAMPle.CoM'
      user.email = mixed_email
      user.save
      expect(user.reload.email).to eq mixed_email.downcase
    end
  end

  describe '#remember' do
    it 'remember_digestが保存されること' do
      expect(user.remember_digest).to be_nil
      user.remember
      expect(user.remember_digest).not_to be_nil
    end
  end

  describe '#authenticated?' do
    context 'remember_digestがnilの場合' do
      it 'falseを返すこと' do
        expect(user.authenticated?(:remember, '')).to be false
      end
    end
  end

  describe '#forget' do
    it 'remember_digestがnilになること' do
      user.remember
      user.forget
      expect(user.remember_digest).to be_nil
    end
  end
end
