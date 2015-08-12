class User < ActiveRecord::Base
  has_many :authorizations
  has_many :memberships, primary_key: :uid
  has_many :lists, through: :memberships
  validates :name, :email, :presence => true


  def point_of_day(query_day)
    today_point = 0
    done_tasks_of_day(query_day).select{|e| e.point != nil }.each do |task|
      if task.point > 0
        today_point += task.point
      elsif task.point == -1 #subtasks have points
        task.done_subtasks_of_day(query_day, time_zone).each do |subtask|
          today_point += subtask.point if subtask.point
        end
      end

    end

    today_point
  end

  def average_point_of_day(query_day)

    last_week_day = (query_day-7.day)
    average_point = 0.0

    done_tasks_of_week(last_week_day ).select{|e| e.point != nil }.each do |task|
      if task.point > 0
        average_point += task.point
      elsif task.point == -1 #subtasks have points
        task.done_subtasks_of_week(last_week_day, time_zone).each do |subtask|
          average_point += subtask.point if subtask.point
        end
      end
    end

    average_point = average_point.to_f / 7.to_f

  end

  def done_tasks_of_day(query_day)
    tasks = []
    arel_record = Task.arel_table
    lists.each do |list|
      tasks = tasks + list.tasks.where(arel_record[:completed_at].gteq(query_day.in_time_zone(time_zone).beginning_of_day))
        .where(arel_record[:completed_at].lt(query_day.in_time_zone(time_zone).end_of_day))

      tasks = tasks + list.tasks.where(:completed_at => nil).where(:point => -1)
    end
    tasks
  end

  def done_tasks_of_week(query_day, *options)
    cwyear = query_day.cwyear
    cweek = query_day.cweek

    arel_record = Task.arel_table

    if !options[0].blank? && options[0][:last_two_weeks]
      s_day = Date.commercial((query_day-7.day).cwyear, (query_day-7.day).cweek ).beginning_of_week
    else
      s_day = Date.commercial(cwyear, cweek).beginning_of_week
    end

    e_day = Date.commercial(cwyear, cweek).end_of_week

    tasks = []

    lists.each do |list|

      tasks = tasks + list.tasks
          .where(arel_record[:completed_at].gteq(s_day.in_time_zone(time_zone).beginning_of_day))
          .where(arel_record[:completed_at].lt(e_day.in_time_zone(time_zone).end_of_day))

      if options[0].blank? || !options[0][:without_subtasks]
        tasks = tasks + list.tasks.where(:completed_at => nil).where(:point => -1).select do |e|
          !e.done_subtasks_of_week(query_day, time_zone).empty?
        end
      end

    end
    tasks
  end

  def todo_tasks(*options)
    arel_record = Task.arel_table

    tasks = []

    lists.each do |list|

      if !options[0].blank? && options[0][:without_due_tasks]
        tasks = tasks + list.tasks.where(:completed_at => nil).where(due_date: nil)
      else
        tasks = tasks + list.tasks.where(:completed_at => nil)
      end

    end
    tasks
  end

  def due_tasks_of_week

    tasks = []

    lists.each do |list|

      tasks = tasks + list.tasks
          .where.not(due_date: nil)
          .where(:completed_at => nil)
    end
    tasks
  end


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
