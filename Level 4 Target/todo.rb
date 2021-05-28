require "active_record"

class Todo < ActiveRecord::Base
  def self.add_task(h)
    self.create!(todo_text: h[:todo_text], due_date: Date.today + h[:due_in_days], completed: false)
  end

  def self.mark_as_complete(id)
    todo = self.find(id)
    todo.completed = true
    todo.save
    todo
  end

  def overdue?
    due_date < Date.today
  end

  def due_today?
    due_date == Date.today
  end

  def due_later?
    due_date > Date.today
  end

  def to_displayable_string
    display_status = completed ? "[X]" : "[ ]"
    display_date = due_today? ? nil : due_date
    "#{id}. #{display_status} #{todo_text} #{display_date}"
  end

  def self.show_list
    puts "My Todo-list\n\n"

    puts "Overdue\n"
    puts all.where("due_date < ? ", Date.today).map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Today\n"
    puts all.where("due_date = ? ", Date.today).map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Later\n"
    puts all.where("due_date > ? ", Date.today).map { |todo| todo.to_displayable_string }
    puts "\n\n"
  end
end
