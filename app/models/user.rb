class User < ActiveRecord::Base
  has_many :authorizations
  has_many :memberships, primary_key: :uid
  has_many :lists, through: :memberships
  validates :name, :email, :presence => true

  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    unless authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      Authorization.create(user: self, provider: auth_hash["provider"], uid: auth_hash["uid"])
    end
  end

  def sync_wunderlist!
    self.sync_wunderlist
    self.reload
  end

  def sync_wunderlist
    auth = authorizations.last
    access_token = auth.access_token
    wunderlist = WunderlistApi.new(access_token)
    root = wunderlist.get("root", nil)

    #0 Compare the root revision
    if ( auth.root_revision < root[:revision])
      raw_lists = wunderlist.get("lists", nil)
      sync_wunderlist_lists(wunderlist, raw_lists)
      auth.update(root_revision: root[:revision])
    end



  end

  def sync_wunderlist_lists(wunderlist, raw_lists)



    #3 Delete the membership between the removed lists and the user
    lists.each do |user_list|
      if ( raw_lists.select{ |item| item[:id] == user_list.id }.empty?)
        memberships.find_by_list_id(user_list.id).destroy
        reload
      end
    end
    raw_memberships = nil

    #2 Add new lists
    raw_lists.each do |raw_list|
      found_list = lists.all.select{ |item| item.id == raw_list[:id] }.first

      if !found_list
        new_list = List.create_by_wunderlist(raw_list)

        raw_memberships = wunderlist.get("memberships",nil) if !raw_memberships
        sync_wunderlist_memberships(wunderlist, raw_memberships)

        raw_tasks = wunderlist.get("tasks", {list_id: raw_list[:id]})
        raw_tasks = raw_tasks.concat(wunderlist.get("tasks", {list_id: raw_list[:id], completed: true}))
        new_list.sync_wunderlist_tasks(wunderlist, raw_tasks)

      elsif found_list.revision < raw_list[:revision]
        found_list.update_by_wunderlist(raw_list)


        raw_memberships = wunderlist.get("memberships",nil) if !raw_memberships
        sync_wunderlist_memberships(wunderlist, raw_memberships)

        found_list.reload

        raw_tasks = wunderlist.get("tasks", {list_id: raw_list[:id]})
        raw_tasks = raw_tasks.concat(wunderlist.get("tasks", {list_id: raw_list[:id], completed: true}))
        found_list.sync_wunderlist_tasks(wunderlist, raw_tasks)

      end

    end
  end

  def sync_wunderlist_memberships(wunderlist, raw_memberships)

    memberships.each do |user_mship|
      if ( raw_memberships.select{ |item| item[:id] == user_mship.id }.empty?)
        user_mship.destroy
      end
    end

    raw_memberships.each do |raw_mship|
      found_mship = memberships.all.select{ |item| item.id == raw_mship[:id] }.first

      if !found_mship
        Membership.create_by_wunderlist(raw_mship)
      elsif found_mship.revision < raw_mship[:revision]
        found_mship.update_by_wunderlist(raw_mship)
      end

    end
  end




end
