# -*- encoding : utf-8 -*-

class ChecklistsController < ApplicationController

  def index
    @checklists = Checklist.order :title
  end

  
  def new
    @checklist = Checklist.new
    @listdata = topics_to_yaml(@checklist.topics.order "ordering")
  end
  
  def edit
    @checklist = Checklist.find(params[:id])
    @listdata = topics_to_yaml(@checklist.topics.order "ordering")
  end
    
  def show
    @checklist = Checklist.find(params[:id])
    @registration = nil

    render :layout => !request.xhr?
  end
    
  def show_registration
    @checklist = Checklist.find(params[:id])
    @registration = Registration.find(params[:registration_id])
    render :action => :show, :layout => !request.xhr?
  end
    
  def update_registration
    @checklist = Checklist.find(params[:id])
    if params[:registration].nil?
      return render :action => :show, :layout => !request.xhr?
    end
    @registration = Registration.find(params[:registration])

    checks = @checklist.selected_checks.where(:registration_id => @registration.id)
    check_map = {}
    checks.each do |a|
      a.selected = false
      check_map[a.checklist_check_id] = a
    end

    params.fetch(:checks,{}).each do |check_id, selected|
      a = check_map.fetch check_id.to_i, SelectedCheck.new
      a.registration = @registration
      a.checklist_check_id = check_id
      a.selected = true;

      check_map[check_id] = a
    end

    check_map.each do |k,a|
      a.save
    end

    render :action => :show, :layout => !request.xhr?
  end

  def create
    begin
      @checklist = Checklist.new params[:checklist]
      @checklist.topics = yaml_to_topics(params[:topics])
      @checklist.save
      
      redirect_to @checklist, :notice => 'Checklist was successfully created.'

    rescue Exception => msg  
      
      @checklist = Checklist.new params[:checklist]
      @listdata = params[:topics]
      @checklist.errors.add(:topics,msg)

      render :action => "new"
    end
  end

  def update
    @checklist = Checklist.find params[:checklist][:id]
    @checklist.title = params[:checklist][:title]
    @checklist.remarks = params[:checklist][:remarks]
    begin
      old_checks = @checklist.checks
      @checklist.topics = yaml_to_topics(params[:topics])
      @checklist.save

      ChecklistTopic.delete_all(:checklist_id => nil)
      old_checks.each do |check|
        if check.topics.empty?
          check.destroy
        end
      end
      
      redirect_to @checklist, :notice => 'Checklist was successfully created.'

    rescue Exception => msg  
      @listdata = params[:topics]
      @checklist.errors.add(:topics,msg)

      render :action => "edit"
    end
  end

  def destroy
    @checklist = Checklist.find(params[:id])
    @checklist.destroy
    redirect_to checklists_path, :notice => 'Course was destroyed'
  end

  private

  def topics_to_yaml (topics)
    StyledYAML.dump format_nice(topics.map{ |topic|
      ret = topic.attributes.reject {|key,value|
        %w(ordering checklist_id scoretype_id).include? key or value.nil? 
      }
      if !topic.scoretype.nil?
        ret["scoretype"] = topic.scoretype.varname unless topic.scoretype.varname == "points"
      end
      ret["checks"] = topic.checks.map do |a|
        hide_ids_from :check, a.attributes.reject {|key,val| 
          %w(ordering checklist_topic_id).include? key or val.nil? or val == 0
        }
      end unless topic.checks.size == 0
      hide_ids_from :topic, ret 
    })
  end

  def yaml_to_topics(yaml)
    ordering = 1
    topics = YAML.load(yaml).map do |thash|
      thash = parse_ids_from :topic, thash
      if thash.has_key? "id"
        begin
          topic = ChecklistTopic.find thash["id"] 
          rescue
          thash.delete "id"
          topic = ChecklistTopic.new
        end
      else 
        topic = ChecklistTopic.new 
      end

      thash.each do |key,val|
        topic[key] = val unless %w(scoretype checks ordering).include? key
      end
      topic.scoretype = Scoretype.find_by_varname thash.fetch("scoretype", "points")
      topic.title = thash["topic"]
      topic.ordering = ordering
      ordering += 1

      check_ordering = 1
      topic.checks = thash.fetch("checks", []).map do |chash|
        chash = parse_ids_from :check, chash
        if chash.has_key? "id"
          begin
            check = ChecklistCheck.find chash["id"] 
            rescue
            chash.delete "id"
            check = ChecklistCheck.new
          end
        else 
          check = ChecklistCheck.new 
        end

        chash.each do |key,val|
          check[key] = val unless %w(ordering).include? key
        end
        check.ordering = check_ordering
        check_ordering += 1

        check.save if chash.has_key? "id"
        
        check
      end

      topic.save if thash.has_key? "id"

      topic
    end
    topics
  end

  def hide_ids_from(key,hash)
    return hash unless hash.has_key? "id"

    key = key.to_s
    id = hash["id"]
    keyval = hash[key]

    hash.delete "id"
    hash.delete key

    ret = {key+" "+id.to_s => keyval}
    hash.each { |k,v| ret[k] = v }
    ret
  end

  def parse_ids_from(idkey,hash)
    idkey = idkey.to_s
    ret = {}
    regexp = "^"+idkey+" ([0-9]+)$"

    hash.each do |key,val|
      if key.match regexp
        ret[idkey] = val
        ret["id"] = $1.to_i
      else
        ret[key] = val
      end
    end

    ret

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
