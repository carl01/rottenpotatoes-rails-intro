class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings=Movie.ratings
    key = params[:key]
    rating_filter = params[:ratings]
    if session[:first?] == nil
      # All checkbox enabled
      session[:rating_filter] = Hash[@all_ratings.zip [1]*@all_ratings.length]
      # Prepare for next invocation of index method
      session[:first?]=false
    end
    if rating_filter==nil || rating_filter.length == 0
      rating_filter = session[:rating_filter]
    else
      session[:rating_filter] = rating_filter
    end
    logger.debug(">>>CI<<< rating_filter is " + rating_filter.to_s)
    if key == "title"
      # @movies = Movie.order(title: :asc)
      @movies = Movie.where(rating: rating_filter.keys).order(title: :asc)
      @title_header_class='hilite'
      @release_date_header_class=''
    elsif key == "release_date"
      @movies = Movie.where(rating: rating_filter.keys).order(release_date: :asc)
      @title_header_class=''
      @release_date_header_class='hilite'      
    else    
      @movies = Movie.where(rating: rating_filter.keys).all
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
end
