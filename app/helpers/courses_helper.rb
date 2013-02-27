module CoursesHelper
  def active course
    return "active" if course.active
    "inactive"
  end

  def sort registrations
    reg = registrations.select{ |r| r.active }.sort_by{ |r| r.user.surename }
    reg + registrations.select{ |r| not r.active }.sort_by{ |r| r.user.surename }
  end

  def active registration
    return "dropped" if not registration.active
    ""
  end
end
