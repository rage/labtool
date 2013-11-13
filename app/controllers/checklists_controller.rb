# -*- encoding : utf-8 -*-

class ChecklistsController < ApplicationController

  def index
    @checklists = Checklist.all
  end

  
  def new
    @checklist = Checklist.new

    q = ChecklistQuestion.new :question => "Mitä kuuluu? (Example question)", :update_callback => <<eos
/*
//Default logic:
this.feedback = "";
this.answers.each(function() {
  if (this.selected) this.feedback += this.feedback;
});
*/
eos
    q.answers << ( ChecklistAnswer.new :answer => "Hyvää", :value => 1, :feedback => "Sinulle kuuluu hyvää" )
    q.answers << ( ChecklistAnswer.new :answer => "Meh", :value => -1, :feedback => "Salailetko jotakin?" )
    @checklist.questions << q

    @listdata = questions_to_yaml(@checklist.questions)
  end
  
  def edit
    @checklist = Checklist.find(params[:id])
    @listdata = questions_to_yaml(@checklist.questions)
  end
    
  def show
    @checklist = Checklist.find(params[:id])
  end

  def create
    begin
      @checklist = Checklist.new params[:checklist]
      @checklist.questions = yaml_to_questions(params[:questions])
      @checklist.save
      
      redirect_to @checklist, :notice => 'Checklist was successfully created.'

    rescue Exception => msg  
      
      @checklist = Checklist.new params[:checklist]
      @listdata = params[:questions]
      @checklist.errors.add(:questions,msg)

      render :action => "new"
    end
  end

  def update
    begin
      @checklist = Checklist.find params[:checklist][:id]
      @checklist.title = params[:checklist][:title]
      @checklist.questions = yaml_to_questions(params[:questions])
      @checklist.save

      ChecklistAnswer.destroy_all(:checklist_question_id => nil)
      ChecklistQuestion.destroy_all(:checklist_id => nil)
      
      redirect_to @checklist, :notice => 'Checklist was successfully created.'

    rescue Exception => msg  
      
      @checklist = Checklist.new params[:checklist]
      @listdata = params[:questions]
      @checklist.errors.add(:questions,msg)

      render :action => "edit"
    end
  end

  def destroy
    @checklist = Checklist.find(params[:id])
    @checklist.destroy
    redirect_to checklists_path, :notice => 'Course was destroyed'
  end

  private

  def questions_to_yaml (questions)
    StyledYAML.dump format_nice(questions.map{ |question|
      ret = question.attributes.reject {|key,value|
        %w(ordering checklist_id scoretype_id).include? key or value.nil? 
      }
      if !question.scoretype.nil?
        ret["scoretype"] = question.scoretype.varname unless question.scoretype.varname == "points"
      end
      ret["answers"] = question.answers.map do |a|
        a.attributes.reject {|key,val| 
          %w(ordering checklist_question_id).include? key or val.nil? or val == 0
        }
      end unless question.answers.size == 0
      ret 
    })
  end

  def yaml_to_questions(yaml)
    ordering = 1
    questions = YAML.load(yaml).map do |qhash|
      question = nil
      question = ChecklistQuestion.find qhash["id"] if qhash.has_key? "id"
      question = ChecklistQuestion.new if question.nil?

      qhash.each do |key,val|
        question[key] = val unless %w(scoretype answers ordering).include? key
      end
      question.scoretype = Scoretype.find_by_varname qhash.fetch("scoretype", "points")
      question.ordering = ordering
      ordering += 1

      answer_ordering = 1
      question.answers = qhash.fetch("answers", []).map do |ahash|
        answer = nil
        answer = ChecklistAnswer.find ahash["id"] if ahash.has_key? "id"
        answer = ChecklistAnswer.new if answer.nil?

        ahash.each do |key,val|
          answer[key] = val unless %w(ordering).include? key
        end
        answer.ordering = answer_ordering
        answer_ordering += 1

        answer.save if ahash.has_key? "id"
        
        answer
      end

      question.save if qhash.has_key? "id"

      question
    end
    questions
  end

  def format_nice (coll)
    if coll.is_a? Hash
      coll.each do |key, value|
        coll[key] = format_nice(value)
      end
    elsif coll.is_a? Array
      coll = coll.map do |value|
        format_nice(value)
      end
    elsif coll.is_a? String and !coll.index("\n").nil?
      coll = StyledYAML.literal(coll)
    end
    coll
  end

end
