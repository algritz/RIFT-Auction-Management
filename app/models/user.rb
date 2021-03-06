require 'digest'



class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation, :creation_code
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :creation_code, :presence => true

  validates :name,  :presence => true,
  :length   => { :maximum => 50 }
  validates :email, :presence => true,
  :format   => { :with => email_regex },
  :uniqueness => { :case_sensitive => false }
  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence     => true,
  :confirmation => true,
  :length       => { :within => 6..40 }

  before_save :encrypt_password

  has_many :sales_listings,  :dependent => :destroy
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = User.first(:conditions => ["id = ?", id], :select => "id, salt, name, is_admin")
    (user && user.salt == cookie_salt) ? user : nil
  end

  ## Start of Private Block ##
  private

  def encrypt_password
    self.salt = make_salt if new_record?
    if encrypt(password) != self.encrypted_password then
    self.encrypted_password = encrypt(password)
    end
  end

  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end

## End of Private block
end


# == Schema Information
#
# Table name: users
#
#  id                 :integer         primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :timestamp
#  updated_at         :timestamp
#  encrypted_password :string(255)
#  salt               :string(255)
#  is_admin           :boolean
#  creation_code      :string(255)
#

