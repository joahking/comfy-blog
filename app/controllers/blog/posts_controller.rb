class Blog::PostsController < ApplicationController

  unless ComfyBlog.config.public_cms_layout
    layout ComfyBlog.config.public_layout
  end

  def index
    #HACK content_for :title, 'content' reach the application layout empty!? no idea why
    @content_for_title = 'Blog - ifeel maps'

    scope = if params[:tag]
      Blog::Post.published.tagged_with(params[:tag])
    elsif params[:category]
      Blog::Post.published.categorized_as(params[:category])
    elsif params[:year]
      scope = Blog::Post.published.for_year(params[:year])
      params[:month] ? scope.for_month(params[:month]) : scope
    else
      Blog::Post.published
    end

    respond_to do |f|
      f.html do
        @posts = if defined? WillPaginate
          scope.paginate :per_page => ComfyBlog.config.posts_per_page, :page => params[:page]
        elsif defined? Kaminari
          scope.page(params[:page]).per(ComfyBlog.config.posts_per_page)
        else
          scope
        end

        if ComfyBlog.config.public_cms_layout
          render :cms_layout => ComfyBlog.config.public_cms_layout
        end
      end
      f.rss do
        @posts = scope.limit(ComfyBlog.config.posts_per_page)
      end
    end
  end

  def archive
    @content_for_title = 'Todas las noticias - Blog de ifeel maps'

    @posts = Blog::Post.published

    respond_to do |f|
      f.html do
        if ComfyBlog.config.public_cms_layout
          render :cms_layout => ComfyBlog.config.public_cms_layout
        end
      end
    end
  end

  def show
    @post = if params[:slug] && params[:year] && params[:month]
      Blog::Post.published.find_by_year_and_month_and_slug!(params[:year], params[:month], params[:slug])
    else
      Blog::Post.published.find(params[:id])
    end

    @content_for_title = "#{@post.title} - Blog de ifeel maps"

    if ComfyBlog.config.public_cms_layout
      render :cms_layout => ComfyBlog.config.public_cms_layout
    end
  rescue ActiveRecord::RecordNotFound
    if defined? ComfortableMexicanSofa
      render :cms_page => '/404', :status => 404
    else
      render :text => I18n.t('comfy_blog.post_not_found'), :status => 404
    end
  end
end
