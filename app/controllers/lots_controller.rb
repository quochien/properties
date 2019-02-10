class LotsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: LotDatatable.new(params, view_context: view_context)
      end
    end
  end

  def show
    @lot = Lot.find(params[:id])
  end
end
