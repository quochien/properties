class BaseDatatable < AjaxDatatablesRails::ActiveRecord
  delegate :image_tag, :lot_path, :link_to, to: :@view

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end
end
