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
    # Get @all_ratings:
    @all_ratings = [] # initialize as empty list.
    movies_list = Movie.all # get all movies
    movies_list.each do |movie|
      rating = movie.rating # for each movie, get its rating.
      if !@all_ratings.include? rating # if we see a new rating, add it to the list.
        @all_ratings += [rating]
      end
    end
    # Get @all_ratings finished

    # if one of params[:sort_accordance] or params[:ratings] is missing, do redirection (to keep RESTful)
    if params[:sort_accordance].nil?
      if session[:sort_accordance].nil?
        sort_accordance = 'none' # When first called movies#index method, don't need to sort anything.
      else
        sort_accordance = session[:sort_accordance]
      end
    else
      sort_accordance = params[:sort_accordance]
      session[:sort_accordance] = params[:sort_accordance]
    end
    
    if params[:ratings].nil?
      if session[:ratings].nil?
        @selected_ratings = @all_ratings # At the very beginning of the session.
      else
        @selected_ratings = session[:ratings]
      end
    else
      @selected_ratings = params[:ratings]
      session[:ratings] = params[:ratings]
    end
    
    if params[:sort_accordance].nil? or params[:ratings].nil?
      redirect_to movies_path({:sort_accordance => sort_accordance, :ratings =>@selected_ratings})
    end
    # Redirection finished
    
    # Sorting part:
    @title_html_class = '' 
    @date_html_class = ''
    if sort_accordance == 'title'
      @movies = Movie.all.order('title')
      @title_html_class = 'hilite'
    elsif sort_accordance == 'date'
      @movies = Movie.all.order('release_date')
      @date_html_class = 'hilite'
    elsif sort_accordance == 'none'
      @movies = Movie.all
    else
      # @movies = Movie.all # should have thrown error here
    end
    # Sorting finish. Get sorted movie list in @movies
    
    # Selecting part:
    @selected_ratings = params[:ratings]
    @movies = @movies.where({rating: @selected_ratings})
    #Selection finished. Get sorted and selected movie list in @movies
    
    # session.clear
    
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
