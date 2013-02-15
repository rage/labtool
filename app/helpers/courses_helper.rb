module CoursesHelper
  def active course
    return "active" if course.active
    "inactive"
  end
end
