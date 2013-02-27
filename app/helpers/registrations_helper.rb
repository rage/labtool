module RegistrationsHelper
  def active registration
    return "dropped" if not registration.active
    ""
  end
end
