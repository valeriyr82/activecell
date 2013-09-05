class ActivityObserver < Mongoid::Observer

  def after_create(activity)
    users = activity.users_to_notify
    users.each do |user|
      Notifications.activity_created(activity.id, user.id).deliver
    end
  end

end
