class List < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  has_many :tasks

  def self.create_by_wunderlist(raw_list)
    create(id: raw_list[:id],
          original_created_at: raw_list[:created_at],
          title: raw_list[:title],
          list_type: raw_list[:list_type],
          revision: raw_list[:revision] )
  end
  def update_by_wunderlist(raw_list)
    update(original_created_at: raw_list[:created_at],
          title: raw_list[:title],
          list_type: raw_list[:list_type],
          revision: raw_list[:revision] )
  end

  def sync_wunderlist_tasks(wunderlist, raw_tasks)
    tasks.each do |t|
      if ( raw_tasks.select{ |item| item[:id] == t.id }.empty?)
        t.destroy
      end
    end

    raw_tasks.each do |raw_task|
      found_task = tasks.all.select{ |item| item.id == raw_task[:id] }.first

      if !found_task
        new_task = Task.create_by_wunderlist(raw_task)

        raw_subtasks = wunderlist.get("subtasks", {task_id: raw_task[:id]})
        # raw_subtasks = raw_subtasks.concat(wunderlist.get("subtasks", {task_id: raw_task[:id], completed: true}))
        new_task.sync_wunderlist_subtasks(raw_subtasks)

      elsif found_task.revision < raw_task[:revision]
        found_task.update_by_wunderlist(raw_task)

        raw_subtasks = wunderlist.get("subtasks", {task_id: raw_task[:id]})
        # raw_subtasks = raw_subtasks.concat(wunderlist.get("subtasks", {task_id: raw_task[:id], completed: true}))
        found_task.sync_wunderlist_subtasks(raw_subtasks)


      end

    end

  end

end
