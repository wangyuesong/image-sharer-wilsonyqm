require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: 'Example User',
      email: 'user@example.com',
      password: 'foobar',
      password_confirmation: 'foobar'
    )
  end

  test 'should be valid' do
    assert_predicate @user, :valid?
  end

  test 'name should be present' do
    @user.name = ''
    assert_predicate @user, :invalid?
    assert_equal ["can't be blank"], @user.errors[:name]
  end

  test 'email should be present' do
    @user.email = '     '
    assert_predicate @user, :invalid?
    assert_equal ["can't be blank", 'is not a valid email address'], @user.errors[:email]
  end

  test 'email is invalid' do
    invalid_addresses = %w(user@.com USERfoo.COM A_US-ER@foo.bar.
                           invalid alice+bob@baz)
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_predicate @user, :invalid?
      assert_equal ['is not a valid email address'], @user.errors[:email]
    end
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn)
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert_predicate @user, :valid?
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_predicate duplicate_user, :invalid?
    assert_equal ['has already been taken'], duplicate_user.errors[:email]
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_predicate @user, :invalid?
    assert_equal ["can't be blank"], @user.errors[:password]
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_predicate @user, :invalid?
    assert_equal ['is too short (minimum is 6 characters)'], @user.errors[:password]
  end

  test 'password does not match' do
    @user.password = 'a' * 8
    @user.password_confirmation = 'b' * 8
    assert_predicate @user, :invalid?
    assert_equal ["doesn't match Password"], @user.errors[:password_confirmation]
  end
end
