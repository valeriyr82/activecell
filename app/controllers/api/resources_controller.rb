class Api::ResourcesController < Api::BaseController
  inherit_resources
  actions :index, :show, :create, :update, :destroy

  private

  def begin_of_association_chain
    current_company
  end
end
