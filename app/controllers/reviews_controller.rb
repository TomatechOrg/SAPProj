class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show edit update destroy ]
  before_action :authenticate_user!,  except: %i[index show]

  # GET /reviews or /reviews.json
  def index
    @reviews = Review.all
    if params[:search] && params[:search] != ""
      sql = "SELECT * FROM reviews WHERE title LIKE '"+params[:search]+"%'"
      @reviews = ActiveRecord::Base.connection.execute(sql).map { Review.new _1 }
    end
    p @reviews
  end

  # GET /reviews/1 or /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
    if current_user != @review.user
      redirect_to(@review)
    end
  end

  # POST /reviews or /reviews.json
  def create
    @review = Review.new(review_params.merge(user_id: current_user.id))

    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: "Review was successfully created." }
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    if current_user != @review.user
      redirect_to(@review)
    end
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: "Review was successfully updated." }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1 or /reviews/1.json
  def destroy
    if current_user == @review.user || current_user.is_moderator?
      @review.destroy!

      respond_to do |format|
        format.html { redirect_to reviews_path, status: :see_other, notice: "Review was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.require(:review).permit(:title, :body)
    end
end
