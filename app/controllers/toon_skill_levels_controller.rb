class ToonSkillLevelsController < ApplicationController
  # GET /toon_skill_levels
  # GET /toon_skill_levels.xml
  def index
    user_toon_list = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]], :select => "id, user_id")
    @toon_skill_levels = ToonSkillLevel.find(:all, :conditions => ["toon_id in (?)", user_toon_list], :select => "id, toon_id, source_id, skill_level")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @toon_skill_levels }
    end
  end

  # GET /toon_skill_levels/1
  # GET /toon_skill_levels/1.xml
  def show
    @toon_skill_level = ToonSkillLevel.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, toon_id, source_id, skill_level")
    users_toon = Toon.find(:first, :conditions => ["id = ?", @toon_skill_level.toon_id], :select => "id, user_id").user_id == current_user[:id]
    respond_to do |format|
      if users_toon then
        format.html # show.html.erb
        format.xml  { render :xml => @toon_skill_level }
      else
        format.html {redirect_to(signin_path, :notice => "You can only see your own toon's professions")}
      end
    end
  end

  # GET /toon_skill_levels/new
  # GET /toon_skill_levels/new.xml
  def new
    @toon_skill_level = ToonSkillLevel.new
    @toon = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]], :order => "name", :select => "id, name")
    @source = Source.find(:all, :conditions => ["crafting_allowed = ?", true], :order => "description", :select => "id, description")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @toon_skill_level }
    end
  end

  # GET /toon_skill_levels/1/edit
  def edit
    @toon_skill_level = ToonSkillLevel.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, toon_id, source_id, skill_level")
    @toon = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]], :order => "name", :select => "id, name")
    @source = Source.find(:all, :conditions => ["crafting_allowed = ?", true], :order => "description", :select => "id, description")
    users_toon = Toon.find(:first, :conditions => ["id = ?", @toon_skill_level.toon_id], :select => "id, user_id").user_id == current_user[:id]
    respond_to do |format|
      if users_toon then
        format.html # show.html.erb
        format.xml  { render :xml => @toon_skill_level }
      else
        format.html {redirect_to(signin_path, :notice => "You can only see your own toon's professions")}
      end
    end
  end

  # POST /toon_skill_levels
  # POST /toon_skill_levels.xml
  def create
    @toon_skill_level = ToonSkillLevel.new(params[:toon_skill_level])
    @source = Source.find(:all, :conditions => ["crafting_allowed = ?", true], :order => "description", :select => "id, description")
    users_toon = Toon.find(:first, :conditions => ["id = ?", @toon_skill_level.toon_id], :select => "id, user_id").user_id == current_user[:id]
    respond_to do |format|
      if @toon_skill_level.save
        format.html { redirect_to(@toon_skill_level, :notice => 'Toon skill level was successfully created.') }
        format.xml  { render :xml => @toon_skill_level, :status => :created, :location => @toon_skill_level }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @toon_skill_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /toon_skill_levels/1
  # PUT /toon_skill_levels/1.xml
  def update
    @toon_skill_level = ToonSkillLevel.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, toon_id, source_id, skill_level")

    respond_to do |format|
      if @toon_skill_level.update_attributes(params[:toon_skill_level])
        format.html { redirect_to(@toon_skill_level, :notice => 'Toon skill level was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @toon_skill_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /toon_skill_levels/1
  # DELETE /toon_skill_levels/1.xml
  def destroy
    @toon_skill_level = ToonSkillLevel.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, toon_id, source_id, skill_level")
    @toon_skill_level.destroy

    respond_to do |format|
      format.html { redirect_to(toon_skill_levels_url) }
      format.xml  { head :ok }
    end
  end
end
