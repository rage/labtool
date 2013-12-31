module ChecklistsHelper

  def show_val val
    #Drop the decimal notation if it's not needed
    val = val.to_i if val.frac == 0
    val
  end

end
