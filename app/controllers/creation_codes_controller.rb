class CreationCodesController < ApplicationController
  before_filter :authenticate_admin
  
  
  # GET /creation_codes
  # GET /creation_codes.xml
  def index
    @creation_codes = CreationCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @creation_codes }
    end
  end

  # GET /creation_codes/1
  # GET /creation_codes/1.xml
  def show
    @creation_code = CreationCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @creation_code }
    end
  end

  # GET /creation_codes/new
  # GET /creation_codes/new.xml
  def new
    @creation_code = CreationCode.new

    @creation_code.creation_code = generate_code
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @creation_code }
    end
  end

  # GET /creation_codes/1/edit
  def edit
    @creation_code = CreationCode.find(params[:id])
  end

  # POST /creation_codes
  # POST /creation_codes.xml
  def create
    @creation_code = CreationCode.new(params[:creation_code])

    respond_to do |format|
      if @creation_code.save
        
        format.html { redirect_to(@creation_code, :notice => 'Creation code was successfully created.') }
        format.xml  { render :xml => @creation_code, :status => :created, :location => @creation_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @creation_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /creation_codes/1
  # PUT /creation_codes/1.xml
  def update
    @creation_code = CreationCode.find(params[:id])

    respond_to do |format|
      if @creation_code.update_attributes(params[:creation_code])
        
        format.html { redirect_to(@creation_code, :notice => 'Creation code was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @creation_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /creation_codes/1
  # DELETE /creation_codes/1.xml
  def destroy
    @creation_code = CreationCode.find(params[:id])
    @creation_code.destroy
    
    respond_to do |format|
      format.html { redirect_to(creation_codes_url) }
      format.xml  { head :ok }
    end
  end

  ## Start Private block

  private

  def generate_code

    Digest::SHA2.hexdigest(Time.now.to_s)

  end

end
