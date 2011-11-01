require 'digest'
class CreationCode < ActiveRecord::Base
   attr_accessible :creation_code, :used
end

# == Schema Information
#
# Table name: creation_codes
#
#  id            :integer         primary key
#  creation_code :string(255)
#  used          :boolean
#  created_at    :timestamp
#  updated_at    :timestamp
#

