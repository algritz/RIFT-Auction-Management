require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end



# == Schema Information
#
# Table name: items
#
#  id                   :integer         primary key
#  description          :string(255)
#  vendor_selling_price :integer
#  vendor_buying_price  :integer
#  source_id            :integer
#  created_at           :timestamp
#  updated_at           :timestamp
#  is_crafted           :boolean
#  to_list              :boolean
#  item_level           :integer
#  note                 :string(255)
#  itemkey              :string(255)
#  rarity               :string(255)
#  icon                 :string(255)
#  soulboundtrigger     :string(255)
#  riftgem              :string(255)
#  salvageskill         :string(255)
#  salvageskilllevel    :integer
#  runebreakskilllevel  :integer
#  isaugmented          :boolean
#

