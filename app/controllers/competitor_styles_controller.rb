class CompetitorStylesController < ApplicationController
  # GET /competitor_styles
  # GET /competitor_styles.xml
  def index
    @competitor_styles = CompetitorStyle.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @competitor_styles }
    end
  end

  # GET /competitor_styles/1
  # GET /competitor_styles/1.xml
  def show
    @competitor_style = CompetitorStyle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @competitor_style }
    end
  end

  # GET /competitor_styles/new
  # GET /competitor_styles/new.xml
  def new
    @competitor_style = CompetitorStyle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @competitor_style }
    end
  end

  # GET /competitor_styles/1/edit
  def edit
    @competitor_style = CompetitorStyle.find(params[:id])
  end

  # POST /competitor_styles
  # POST /competitor_styles.xml
  def create
    @competitor_style = CompetitorStyle.new(params[:competitor_style])

    respond_to do |format|
      if @competitor_style.save
        format.html { redirect_to(@competitor_style, :notice => 'Competitor style was successfully created.') }
        format.xml  { render :xml => @competitor_style, :status => :created, :location => @competitor_style }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @competitor_style.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /competitor_styles/1
  # PUT /competitor_styles/1.xml
  def update
    @competitor_style = CompetitorStyle.find(params[:id])

    respond_to do |format|
      if @competitor_style.update_attributes(params[:competitor_style])
        format.html { redirect_to(@competitor_style, :notice => 'Competitor style was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @competitor_style.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /competitor_styles/1
  # DELETE /competitor_styles/1.xml
  def destroy
    @competitor_style = CompetitorStyle.find(params[:id])
    @competitor_style.destroy

    respond_to do |format|
      format.html { redirect_to(competitor_styles_url) }
      format.xml  { head :ok }
    end
  end
end
