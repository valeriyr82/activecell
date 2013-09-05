class TaskObserver < Mongoid::Observer

  def after_create(task)
    users = task.users_to_notify
    users.each do |user|
      Notifications.task_created(task.id, user.id).deliver
    end
  end

  def after_update(task)
    return unless task.has_been_completed?

    users = task.users_to_notify
    users.each do |user|
      Notifications.task_completed(task.id, user.id).deliver
    end
  end

end
