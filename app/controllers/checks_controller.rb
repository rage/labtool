class ChecksController < ApplicationController

  def index
    @uncategorised = ChecklistCheck.find_all_by_type_id nil
    @types = Checktype.includes(:checks, :topics_checks).order :name
  end

  def new
  end
  def edit
  end
  def show
  end
  def create
  end
  def update
  end
  def reorder
  end
  def destroy
    #@checklist = Checklist.find(params[:id])
    #@checklist.destroy
    #redirect_to checklists_path, :notice => 'Course was destroyed'
  end

end
