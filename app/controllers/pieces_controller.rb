class PiecesController < ApplicationController

  before_action :authenticate_user!

  def new
  end

  def update
    @piece = Piece.find(params[:id])
    @piece.update(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space))
    if params[:piece][:folders] == ""
      @piece.folder_list = "Uncategorized"
    else
      @piece.folder_list = params[:piece][:folders]
    end
    @piece.user_id = current_user.id
    @piece.save
    @piece.reload

    params[:piece][:piece_id] = @piece.id
    @log = Log.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space, :piece_id))
    @log.user_id = current_user.id
    @log.save

    respond_to do | format |  
      format.json { render :json => @piece.id }
    end
  end
 
  def create
    # render text: params.inspect

    @piece = Piece.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space))
    if params[:piece][:folders] == ""
      @piece.folder_list = "Uncategorized"
    else
      @piece.folder_list = params[:piece][:folders]
    end
    @piece.user_id = current_user.id
    @piece.save
    @piece.reload

    params[:piece][:piece_id] = @piece.id
    @log = Log.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space, :piece_id))
    @log.user_id = current_user.id
    @log.save

    respond_to do | format |  
      format.html { redirect_to @piece }
      format.json { render :json => @piece.id }
    end
  end

  def show
    # @piece = Piece.find(params[:id])
    @piece = Piece.where(:user_id => current_user.id, :id => params[:id]).first
    @pieces = Piece.where(:user_id => current_user.id)
    @folder = @pieces.folder_counts
    if @piece == nil 
      @error = "not your stuff"
    else
      @log = Log.where(piece_id: @piece.id)
    end
  end

  def index
    @pieces = Piece.where(:user_id => current_user.id)
    @folder = @pieces.folder_counts
  end

  def pos
    text = params[:text]

    tgr = EngTagger.new
    possed_text = tgr.add_tags(text) 

    params[:possed] = possed_text

    # result = []
    # result[:unpossed] = text
    # result[possed] = possed_text

    respond_to do | format |  
      format.html { render :html => "asdf" }
      format.json { render :json => params }
    end
  end

  # def piece_params
  #   params.require(:user).permit(:name, :tag_list) ## Rails 4 strong params usage
  # end

end
