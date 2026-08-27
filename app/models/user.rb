class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Returns the user's full name if present, otherwise falls back to the
  # part of the email address before the @ sign so the UI never shows a bare email.
  def display_name
    full_name.presence || email.to_s.split("@").first.capitalize
  end
end
