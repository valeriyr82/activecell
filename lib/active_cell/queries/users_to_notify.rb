# An experimental pattern (it could be used to refactor other smelly parts in the code)
# Implements "Query Object" pattern taken from http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models
class ActiveCell::Queries::UsersToNotify < BasicObject
  attr_reader :relation
  attr_reader :user_id_to_exclude

  class << self
    def for(relation, options = {})
      query = new(relation)
      query.except(options[:except])
      query
    end
  end

  def initialize(relation = User.all)
    @relation = relation
  end

  # User to exclude from notifications
  def except(user_or_id)
    @user_id_to_exclude = if user_or_id.respond_to?(:_id)
                            user_or_id.id
                          else
                            user_or_id
                          end
    self
  end

  private

  def method_missing(method, *args, &block)
    scoped.send(method, *args, &block)
  end

  def scoped
    scoped = relation

    # Select only users with enabled notifications
    scoped = scoped.where(email_notifications: true)

    # Exclude an user
    if user_id_to_exclude.present?
      scoped = scoped.where(:id.ne => user_id_to_exclude)
    end

    scoped
  end

end
