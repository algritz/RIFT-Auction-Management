require 'digest'
class CreationCode < ActiveRecord::Base
   attr_accessible :creation_code, :used
end
