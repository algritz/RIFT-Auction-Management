class ItemNotesController < ApplicationController
  before_filter :authenticate
  # GET /item_notes
  # GET /item_notes.json
  def index
    @item_notes = ItemNote.find(:all, :conditions => ["user_id = ?", current_user[:id]])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @item_notes }
    end
  end

  # GET /item_notes/1
  # GET /item_notes/1.json
  def show
    @item_note = ItemNote.find(params[:id])
    if @item_note.user_id == current_user[:id] then
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @item_note }
      end
    else
      respond_to do |format|
        format.html { redirect_to item_notes_path, notice: 'You can only view your own notes.'}
      end
    end
  end

  # GET /item_notes/new
  # GET /item_notes/new.json
  def new
    @item_note = ItemNote.new
    @items = Item.all_cached_item
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item_note }
    end
  end

  # GET /item_notes/1/edit
  def edit
    @item_note = ItemNote.find(params[:id])
    @items = Item.all_cached_item
    if @item_note.user_id == current_user[:id] then
      respond_to do |format|
        format.html # edit.html.erb
        format.json { render json: @item_note }
      end
    else
      respond_to do |format|
        format.html { redirect_to item_notes_path, notice: 'You can only edit your own notes.'}
      end
    end
  end

  # POST /item_notes
  # POST /item_notes.json
  def create
    @item_note = ItemNote.new(params[:item_note])
    @items = Item.all_cached_item
    respond_to do |format|
      if @item_note.save
        format.html { redirect_to @item_note, notice: 'Item note was successfully created.' }
        format.json { render json: @item_note, status: :created, location: @item_note }
      else
        format.html { render action: "new" }
        format.json { render json: @item_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /item_notes/1
  # PUT /item_notes/1.json
  def update
    @item_note = ItemNote.find(params[:id])
    @items = Item.all_cached_item
    respond_to do |format|
      if @item_note.update_attributes(params[:item_note])
        format.html { redirect_to @item_note, notice: 'Item note was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @item_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /item_notes/1
  # DELETE /item_notes/1.json
  def destroy
    @item_note = ItemNote.find(params[:id])
    @item_note.destroy
    if @item_note.user_id == current_user[:id] then
      respond_to do |format|
        format.html { redirect_to item_notes_url }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to item_notes_path, notice: 'You can only delete your own notes.'}
      end
    end
  end
end

