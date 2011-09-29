class CompetitorsController < ApplicationController
  before_filter :authenticate
  caches_action :index
  caches_action :show, :layout => false
  # GET /competitors
  # GET /competitors.xml
  def index
    @competitors = Competitor.paginate(:page => params[:page] , :select => 'distinct id, name, competitor_style_id, source_id', :order => 'name, source_id', :conditions => ["user_id = ?", current_user.id])
    @competitor_styles = CompetitorStyle.find(:all, :select => 'id, description')
    @sources_name = Source.find(:all, :select => 'id, description')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @competitors }
    end

  end

  # GET /competitors/1
  # GET /competitors/1.xml
  def show
    @competitor = Competitor.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, name, competitor_style_id, source_id")
    @competitor_styles = CompetitorStyle.find(:all, :select => 'id, description')
    @sources_name = Source.find(:all, :select => 'id, description')

    respond_to do |format|
      if is_current_user?(@competitor.user_id) then
        format.html # show.html.erb
        format.xml  { render :xml => @competitor }
      else
        format.html { redirect_to(competitors_path, :notice => "You can only see your own competition.")}
      end
    end
  end

  # GET /competitors/new
  # GET /competitors/new.xml
  def new
    @competitor = Competitor.new
    @competitor_styles = CompetitorStyle.find(:all, :select => 'id, description')
    @sources_name = Source.find(:all, :select => 'id, description')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @competitor }
    end
  end

  # GET /competitors/1/edit
  def edit
    @competitor = Competitor.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, name, competitor_style_id, source_id")
    @competitor_styles = CompetitorStyle.find(:all, :select => 'id, description')
    @sources_name = Source.find(:all, :select => 'id, description')
    if !is_current_user?(@competitor.user_id) then
      redirect_to(competitors_path, :notice => "You can only edit your own competition.")
    end
  end

  # POST /competitors
  # POST /competitors.xml
  def create
    @competitor = Competitor.new(params[:competitor])

    respond_to do |format|
      if @competitor.save
        expire_action :action => :index
        format.html { redirect_to(@competitor, :notice => 'Competitor was successfully created.') }
        format.xml  { render :xml => @competitor, :status => :created, :location => @competitor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @competitor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /competitors/1
  # PUT /competitors/1.xml
  def update
    @competitor = Competitor.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, name, competitor_style_id, source_id")

    respond_to do |format|
      if @competitor.update_attributes(params[:competitor])
        expire_action :action => :index
        format.html { redirect_to(@competitor, :notice => 'Competitor was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @competitor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /competitors/1
  # DELETE /competitors/1.xml
  def destroy
    @competitor = Competitor.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, name, competitor_style_id, source_id")
    @competitor.destroy
    expire_action :action => :index
    respond_to do |format|
      format.html { redirect_to(competitors_url) }
      format.xml  { head :ok }
    end
  end
end
