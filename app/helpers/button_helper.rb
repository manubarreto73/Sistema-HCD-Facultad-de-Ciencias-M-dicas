# frozen_string_literal: true

# Esta clase busca centralizar los botones y ahorrar código
module ButtonHelper
  CLOSE_BUTTON_CLASS = 'bg-gray-200 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-300 transition font-medium'
  NEW_BUTTON_CLASS   = 'bg-gray-800 text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition font-medium'

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

  def tab_button(text:, tab:, current_tab:, path:)
    active = (tab == current_tab)

    classes = [
      'px-4', 'py-2',
      'rounded-t-md',
      'text-sm', 'font-semibold', 'text-gray-700',
      'transition',
      active ? 'bg-gray-100' : 'bg-gray-400 hover:bg-gray-300'
    ].join(' ')

    link_to path, class: 'group' do
      content_tag(:div, text, class: classes)
    end
  end
end
