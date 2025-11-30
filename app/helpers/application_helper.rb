module ApplicationHelper
  def error_class(resource, field)
    resource.errors[field].any? ? "border-red-500 ring-red-200 focus:border-red-600" : ""
  end
end
