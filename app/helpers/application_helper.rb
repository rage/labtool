module ApplicationHelper
  def label status
    return "cancel participation" if status
    "participate"
  end
end
