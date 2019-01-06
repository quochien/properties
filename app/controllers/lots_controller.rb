class LotsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: LotDatatable.new(params)
      end
    end
  end
end
