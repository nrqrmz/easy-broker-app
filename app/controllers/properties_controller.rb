class PropertiesController < ApplicationController
  def show
    @property = Property.find_by!(public_id: params[:public_id])
    @referrer_chat_id = params[:chat_id]
  end
end
