class User < ActiveRecord::Base
  after_create :generate_api_key

  has_many :groups_users
  has_many :groups, :through => :groups_users
  has_one :api_key
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :groups

  def generate_api_key
    ApiKey.create!(:role => 'User', :User_id => self.id)
  end
end
