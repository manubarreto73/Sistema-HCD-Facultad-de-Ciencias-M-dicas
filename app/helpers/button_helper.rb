# frozen_string_literal: true

# Esta clase busca centralizar los botones y ahorrar código
module ButtonHelper
  CLOSE_BUTTON_CLASS = 'bg-gray-200 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-300 transition font-medium'
  NEW_BUTTON_CLASS   = 'bg-primary-color text-white px-4 py-2 rounded-lg transition font-medium'
  DELETE_BUTTON_CLASS = 'bg-primary-color text-white px-4 py-2 rounded-lg transition font-medium'
  ACTIVE_TAB         = 'px-4 py-2 rounded-t-md text-sm font-semibold transition bg-gray-100 text-gray-900'
  NON_ACTIVE_TAB     = 'px-4 py-2 rounded-t-md text-sm font-semibold transition bg-gray-300 text-gray-600 hover:bg-gray-200'

  def new_modal_button(title, path)
    link_to title,
            path,
            data: { turbo_frame: 'modal' },
            class: NEW_BUTTON_CLASS
  end

  def close_modal_button
    link_to 'Cancelar', '#', data: { action: 'click->modal#close' },
                             class: CLOSE_BUTTON_CLASS
  end

  def close_modal_custom_title(text)
    link_to text, '#', data: { action: 'click->modal#close' },
                             class: CLOSE_BUTTON_CLASS
  end

  def delete_button(path)
    link_to 'Eliminar', path,
        data: { turbo_method: :delete },
        class: DELETE_BUTTON_CLASS
  end

  def tab_button(text:, count:, path:)
    current_treated = params[:treated].to_s == 'true'
    tab_treated     = path[:treated].to_s == 'true'

    active = current_treated == tab_treated
    classes = active ? ACTIVE_TAB : NON_ACTIVE_TAB

    text = "#{text} (#{count})" if count.positive?

    link_to path, class: 'group' do
      content_tag(:div, text, class: classes)
    end
  end

  def download_pdf_button(path:)
    link_to path, class: 'group' do
      content_tag(:div, 'Descargar PDF', class: ACTIVE_TAB)
    end
  end

  def sortable(column, label)
    direction = (params[:sort] == column && params[:direction] == "asc") ? "desc" : "asc"

    label = "#{label} ^" if direction == 'desc'
    link_to label, request.query_parameters.merge(sort: column, direction: direction), class: "underline cursor-pointer"
  end

  def header_button(title, path)
    active = current_page?(path)
    link_to title, path, class: "transition underline underline-offset-4 hover:underline-offset-8 #{'text-green-200' if active}"
  end

  def tab_button_agenda(text:, count:, path:)
    current_treated = params[:treated].to_s == 'true'
    tab_treated     = path[:treated].to_s == 'true'

    active = current_treated == tab_treated
    classes = active ? ACTIVE_TAB : NON_ACTIVE_TAB
    div_id =  text.downcase.gsub(' ', '_')
    text = "#{text} (#{count})" if count.positive?

    link_to path, class: 'group' do
      content_tag(:div, text, class: classes, id: div_id)
    end
  end
end
