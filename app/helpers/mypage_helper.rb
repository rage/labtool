module MypageHelper
  def label status
    return "cancel participation" if status
    "participate"
  end
end