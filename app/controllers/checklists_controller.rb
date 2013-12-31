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

  def edit_values
    @checklist = Checklist.find params[:id]
  end
  def update_values
    @checklist = Checklist.find params[:id]
    topics = params[:checks]

    @checklist.topics_checks.includes(:check).each do |link|
      vals = topics[link.id.to_s]
      unless vals.nil?
        link.value = BigDecimal(vals["value"])
        link.unchecked_value = BigDecimal(vals["unchecked_value"])
        link.check.feedback = vals["feedback"]
        link.check.missing_feedback = vals["missing_feedback"]

        link.check.save
        link.save
      end
    end

    #Integer(,10)

    if params[:new_check].nil?
      redirect_to @checklist, :notice => 'Checklist was successfully updated.'
    else
      params[:new_check_for].select{|k,v| v["check"] != "" }.each do |k,v|
        topic = ChecklistTopic.find k
        ordering = topic.topics_checks.length

        check = ChecklistCheck.new v
        check.save

        link = ChecklistTopicsCheck.new
        link.topic = topic
        link.ordering = ordering
        link.check = check
        link.save
      end

      redirect_to edit_checklist_values_path(@checklist)
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
        %w(title ordering checklist_id scoretype_id).include? key or value.nil? 
      }
      ret["topic"] = topic.title
      if !topic.scoretype.nil?
        ret["scoretype"] = topic.scoretype.varname unless topic.scoretype.varname == "points"
      end
      ret["checks"] = topic.topics_checks.includes(:topic).map do |a|
        c = hide_ids_from :check, a.check.attributes.select {|key,val| 
          %w(id check varname feedback missing_feedback).include? key and !val.nil? and val != ""
        }
        c["value"] = a.value unless a.value == 0
        c["unchecked_value"] = a.unchecked_value unless a.unchecked_value == 0
        c
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
          topic = ChecklistTopic.new
        end
      else 
        topic = ChecklistTopic.new 
      end

      thash.each do |key,val|
        topic[key] = val unless %w(id topic scoretype checks ordering).include? key
      end

      topic.scoretype = Scoretype.find_by_varname thash.fetch("scoretype", "points")
      topic.title = thash["topic"]
      topic.ordering = ordering

      links = topic.topics_checks.includes(:check).index_by(&:checklist_check_id)
      ordering += 1

      check_ordering = 1
      topic.topics_checks = thash.fetch("checks", []).map do |chash|
        chash = parse_ids_from :check, chash
        if chash.has_key? "id" and not links[chash["id"]].nil?
          link = links[chash["id"]]
          check = link.check
        else 
          link = ChecklistTopicsCheck.new
          begin
            if chash.has_key? "id"
              check = ChecklistCheck.find chash["id"]
            else
              check = ChecklistCheck.new
            end
          rescue Exception => msg  
            check = ChecklistCheck.new
          end
          link.check = check
        end

        chash["feedback"] ||= ""
        chash["missing_feedback"] ||= ""
        chash.each do |key,val|
          check[key] = val unless %w(id ordering value unchecked_value).include? key
        end

        link.ordering = check_ordering
        link.value = chash["value"] || 0
        link.unchecked_value = chash["unchecked_value"] || 0
        check_ordering += 1

        if chash.has_key? "id"
          check.save 
          link.save
        end
        
        link
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
