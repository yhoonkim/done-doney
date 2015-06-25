class Subtask < ActiveRecord::Base
  belongs_to :task

  def self.create_by_wunderlist(raw_subtask)
    create(id: raw_subtask[:id],
          original_created_at: raw_subtask[:original_created_at],
          created_by_id: raw_subtask[:created_by_id],
          task_id: raw_subtask[:task_id],
          title: raw_subtask[:title],
          completed_by_id: raw_subtask[:completed_by_id],
          completed_at: raw_subtask[:completed_at],
          point: get_point(raw_subtask[:title]),
          revision: raw_subtask[:revision]
           )
  end
  def update_by_wunderlist(raw_subtask)
    update(original_created_at: raw_subtask[:original_created_at],
          created_by_id: raw_subtask[:created_by_id],
          task_id: raw_subtask[:task_id],
          title: raw_subtask[:title],
          completed_by_id: raw_subtask[:completed_by_id],
          completed_at: raw_subtask[:completed_at],
          point: get_point(raw_subtask[:title]),
          revision: raw_subtask[:revision])
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

end
