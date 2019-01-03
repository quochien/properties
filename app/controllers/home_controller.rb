class HomeController < ApplicationController
  def index
    @lots = Lot.order(:id)
  end
end
