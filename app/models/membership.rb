class Membership < ActiveRecord::Base
  belongs_to :list
  belongs_to :user, primary_key: :uid
  def self.create_by_wunderlist(raw_mship)
    create(id: raw_mship[:id],
          revision: raw_mship[:revision],
          user_id: raw_mship[:user_id],
          list_id: raw_mship[:list_id],
          state: raw_mship[:state],
          owner: raw_mship[:owner],
          muted: raw_mship[:muted] )
  end
  def update_by_wunderlist(raw_mship)
    update(revision: raw_mship[:revision],
          user_id: raw_mship[:user_id],
          list_id: raw_mship[:list_id],
          state: raw_mship[:state],
          owner: raw_mship[:owner],
          muted: raw_mship[:muted])
  end
end
