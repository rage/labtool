module UsersHelper
  def review_point_label points
    return "give points" if points.nil?
    "update points"
  end
end
