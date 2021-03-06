require_relative "test_helper"

class UsersTest < TestCase
  include Rack::Test::Methods

  def test_users_show_route
     user = User.create!(
      display_name: "testalice1", 
      username: "testalice1", 
      email: "testalice1.dee@mail.com",
      email_confirmation: "testalice1.dee@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    get "/users/testalice1", {}, 'rack.session' => {:user_id => user.id}
    assert last_response.ok?
    assert last_response.body.include? "Profile for testalice1"
  end

  def test_users_show_for_unknown_user
     user = User.create!(
      display_name: "testalice1", 
      username: "testalice1", 
      email: "testalice1.dee@mail.com",
      email_confirmation: "testalice1.dee@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    get "/users/alice2", {}, 'rack.session' => {:user_id => user.id}
    assert_equal 404, last_response.status
    assert last_response.body.include? "Page not found"
  end

  def test_users_index
    User.create!(
      display_name: "testalice3", 
      username: "testalice3", 
      email: "testalice3.dee@mail.com",
      email_confirmation: "testalice3.dee@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    User.create!(
      display_name: "Louis4", 
      username: "louis4", 
      email: "louis4.pil@mail.com",
      email_confirmation: "louis4.pil@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    get "/users"
    assert last_response.ok?
    assert last_response.body.include? "testalice3"
    assert last_response.body.include? "louis4"
  end

  def test_user_images_list
    louis5 = User.create!(
      display_name: "Louis5", 
      username: "louis5", 
      email: "louis5.pil@mail.com",
      email_confirmation: "louis5.pil@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    image = Image.create!(
      image_url: "/images/image1.jpg",
      comment: "test",
      user: louis5,
    )
    get "/users/louis5", {}, 'rack.session' => {:user_id => louis5.id}

    assert last_response.ok?
    assert last_response.body.include? image.image_url
  end

  def test_user_with_no_images
    testalice = User.create!(
      display_name: "testalice", 
      username: "testalice", 
      email: "testalice.dee@mail.com",
      email_confirmation: "testalice.dee@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    louis = User.create!(
      display_name: "Louis", 
      username: "louis",
      email: "louis.pil@mail.com",
      email_confirmation: "louis.pil@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    image = Image.create!(
      image_url: "/images/image1.jpg",
      comment: "test",
      user: louis,
    )
    get "/users/testalice", {}, 'rack.session' => {:user_id => testalice.id}

    assert last_response.ok?
    refute last_response.body.include? image.image_url
  end

  def test_user_valid
    mittens2 = User.new(
      display_name: "Mittens2", 
      username: "mittens2", 
      email: "mittens2.pil@mail.com",
      email_confirmation: "mittens2.pil@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    assert mittens2.valid?
  end

  def test_username_present
    username_present = User.new(
      display_name: "Usernamepresent",
      username: "temporaryusernamepresent",
      email: "username@present.com",
      email_confirmation: "username@present.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    username_present.username = "       "
    assert username_present.invalid?
  end

  def test_username_length
    usernamelength = User.new(
      display_name: "Usernamelength", 
      username: "temporaryusernamelength",
      email: "username@length.com",
      email_confirmation: "username@length.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    usernamelength.username = "a"*51 
    assert usernamelength.invalid?
  end

  def test_username_format
    usernameformat = User.new(
      display_name: "Usernameformat", 
      email: "username@format.com", 
      email_confirmation: "username@format.com", 
      username: "temporary",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    usernameformat.username = "Alice" #capitalised
    assert usernameformat.invalid?

    usernameformat.username = "@alice" #contains @
    assert usernameformat.invalid?

    usernameformat.username = "alice dee" #contains space 
    assert usernameformat.invalid?
  end

  def test_username_unique
    User.create!(
      display_name: "Uniqueuser", 
      username: "uniqueuser", 
      email: "uniqueuser@mail.com",
      email_confirmation: "uniqueuser@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    duplicate_username = User.new(
      display_name: "Uniqueuser2", 
      username: "uniqueuser2", 
      email: "uniqueuser2@mail.com",
      email_confirmation: "uniqueuser2@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    duplicate_username.username = "uniqueuser"
    assert duplicate_username.invalid?
  end

  def test_email_present
    emailpresent = User.new(
      display_name: "Emailpresent",
      username: "emailpresent",
      email: "temp@mail.com",
      email_confirmation: "temp@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    emailpresent.email = "     "
    assert emailpresent.invalid?
  end

  def test_email_length
    emaillength = User.new(
      username: "emaillength", 
      email: "temporary@length.com",
      email_confirmation: "temporary@length.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    emaillength.email = "a" * 255 + "@example.com"
    assert emaillength.invalid?
  end

  def test_email_format
    emailformat = User.new(
      display_name: "emailformat", 
      username: "emailformat", 
      email: "temporary@email.com",
      email_confirmation: "temporary@email.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )

    emailformat.email = "aliceatmail.com" #no @
    assert emailformat.invalid?

    emailformat.email = "aliceatmail@com" #no .
    assert emailformat.invalid?

    emailformat.email = "alice@mail."     #no com
    assert emailformat.invalid?

    emailformat.email = "alice@mail"      #no @.com 
    assert emailformat.invalid?

  end

  def test_email_unique
    User.create!(
      display_name: "testalice7", 
      username: "testalice7", 
      email: "testalice7.dee@mail.com",
      email_confirmation: "testalice7.dee@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    duplicate_email = User.new(
      display_name: "testalice8", 
      username: "testalice8", 
      email: "testalice8.dee@mail.com",
      email_confirmation: "testalice8.dee@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    duplicate_email.email = "testalice7.dee@mail.com"
    assert duplicate_email.invalid?
  end

  def test_password_present
    passwordpresent = User.new(
      display_name: "Passwordpresent",
      username: "passwordpresent",
      email: "passwordpresent@mail.com",
      email_confirmation: "passwordpresent@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    passwordpresent.password_confirmation = "     "
    passwordpresent.password = "     "
    assert passwordpresent.invalid?
  end

  def test_password_confirmation
    passwordconfirmation = User.new(
      display_name: "Passwordconfirmation",
      username: "passwordconfirmation",
      email: "passwordconfirmation@mail.com",
      email_confirmation: "passwordconfirmation@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    passwordconfirmation.password = "foobar1"
    passwordconfirmation.password_confirmation = "foobar2"
    assert passwordconfirmation.invalid?
    assert passwordconfirmation.errors[:password_confirmation].any?
  end

  def test_email_confirmation
    emailconfirmation = User.new(
      display_name: "emailconfirmation",
      username: "emailconfirmation",
      email: "emailconfirmation@mail.com",
      email_confirmation: "emailconfirmation@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    )
    emailconfirmation.email = "emailconfirmation@mail.com"
    emailconfirmation.email = "email.confirmation@mail.com"
    assert emailconfirmation.invalid?
    assert emailconfirmation.errors[:email_confirmation].any?
  end

  def test_valid_signup
    assert_equal 0, User.count
    post "/signup",
      display_name: "emailconfirmation",
      username: "emailconfirmation",
      email: "emailconfirmation@mail.com",
      email_confirmation: "emailconfirmation@mail.com",
      password: "foobar1",
      password_confirmation: "foobar1"
    assert_equal 1, User.count
  end

  def test_sessions_enabled
    

  end
end
