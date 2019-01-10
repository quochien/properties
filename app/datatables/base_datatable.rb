class BaseDatatable < AjaxDatatablesRails::ActiveRecord
  delegate :image_tag, to: :@view

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end
end
