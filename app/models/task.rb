class Task < ActiveRecord::Base
  belongs_to :list
  has_many :subtasks


  def partly_completed_at
    completed_at || subtasks.maximum(:completed_at)
  end

  def has_subpoint?
    point == -1
  end

  def total_subpoint
    raise "It doesn't have subpoints" if !has_subpoint?
    total = 0
    subtasks.each do |subtask|
      total += subtask.point if subtask.point
    end
    total
  end

  def total_completed_subpoint
    raise "It doesn't have subpoints" if !has_subpoint?
    total = 0
    subtasks.each do |subtask|
      total += subtask.point if subtask.point && subtask.completed_at
    end
    total
  end

  def done_subtasks_of_day(query_day, time_zone)

    arel_record = Subtask.arel_table
    subtasks.where(arel_record[:completed_at].gteq(query_day.in_time_zone(time_zone).beginning_of_day))
            .where(arel_record[:completed_at].lt(query_day.in_time_zone(time_zone).end_of_day))

  end

  def done_subtasks_of_week(query_day, time_zone)
    arel_record = Subtask.arel_table
    s_day = Date.commercial(query_day.cwyear, query_day.cweek).beginning_of_week
    e_day = Date.commercial(query_day.cwyear, query_day.cweek).end_of_week

    arel_record = Subtask.arel_table
    subtasks.where(arel_record[:completed_at].gteq(s_day.in_time_zone(time_zone).beginning_of_day))
            .where(arel_record[:completed_at].lt(e_day.in_time_zone(time_zone).end_of_day))
  end


  def self.create_by_wunderlist(raw_task)
    create(id: raw_task[:id],
          assignee_id: raw_task[:assignee_id],
          assigner_id: raw_task[:assigner_id],
          original_created_at: raw_task[:created_at],
          created_by_id: raw_task[:created_by_id],
          due_date: raw_task[:due_date],
          list_id: raw_task[:list_id],
          starred: raw_task[:starred],
          title: raw_task[:title],
          completed_by_id: raw_task[:completed_by_id],
          completed_at: raw_task[:completed_at],
          point: get_point(raw_task[:title]),
          revision: raw_task[:revision],
           )
  end
  def update_by_wunderlist(raw_task)
    update(assignee_id: raw_task[:assignee_id],
          assigner_id: raw_task[:assigner_id],
          original_created_at: raw_task[:created_at],
          created_by_id: raw_task[:created_by_id],
          due_date: raw_task[:due_date],
          list_id: raw_task[:list_id],
          starred: raw_task[:starred],
          title: raw_task[:title],
          completed_by_id: raw_task[:completed_by_id],
          completed_at: raw_task[:completed_at],
          point: get_point(raw_task[:title]),
          revision: raw_task[:revision], )
  end


  def self.get_point(title)
    regex = /^\[([0-9*]+)\]/
    if matching = regex.match(title)
      if matching[1] == "*"
        -1
      else
        matching[1].to_i
      end
    end

  end

  def get_point(title)
    regex = /^\[([0-9*]+)\]/
    if matching = regex.match(title)
      if matching[1] == "*"
        -1
      else
        matching[1].to_i
      end
    end

  end

  def title_with_new_point(new_point)
    regex = /^\[([0-9*]+)\](.*)$/
    if matching = regex.match(title)
      "[#{new_point}]" + matching[2]
    else
      title
    end
  end

  def sync_wunderlist_subtasks(raw_subtasks)
    subtasks.each do |st|
      if ( raw_subtasks.select{ |item| item[:id] == st.id }.empty?)
        st.destroy
      end
    end

    raw_subtasks.each do |raw_subtask|
      found_subtask = subtasks.all.select{ |item| item.id == raw_subtask[:id] }.first

      if !found_subtask
        Subtask.create_by_wunderlist(raw_subtask)

      elsif found_subtask.revision < raw_subtask[:revision]
        found_subtask.update_by_wunderlist(raw_subtask)

      end

    end
  rescue
    raise raw_subtasks.inspect
  end

end
