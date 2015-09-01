module ReportsHelper
  def pretty_title(title)
    regex = /^\[([0-9*]+)\](.*)$/
    if matching = regex.match(title)
      matching[2]
    else
      title
    end
  end

  def point_to_bgcolor(point)

    if point == 1
      "green lighten-2"
    elsif point == 2
      "lime"
    elsif point == 3
      "yellow"
    elsif point == 5
      "orange"
    elsif point == 8
      "deep-orange lighten-2"
    else
      "gray"
    end
  end

  def point_to_textcolor(point)
    if point == 1
      "green-text text-lighten-2"
    elsif point == 2
      "lime-text"
    elsif point == 3
      "yellow-text"
    elsif point == 5
      "orange-text"
    elsif point == 8
      "deep-orange-text text-lighten-2"
    else
      "gray-text"
    end
  end

  def dropdown_hash(deco_task, parent_task)

    if deco_task.id && deco_task
      hash = deco_task.id.to_s
    else
      hash = "new-task"
    end

    hash += parent_task.id.to_s if parent_task
    hash
  end
end
